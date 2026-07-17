import 'package:flutter/foundation.dart';
import '../../models/production/model_jobwork.dart';
import '../../models/production/model_cutting.dart';
import '../core/service_supabase.dart';

/// Suggestion structure representing a match candidate between an unlinked Stitching Dispatch and an open Cutting Card.
class CuttingLinkSuggestion {
  final JobDispatchModel dispatch;
  final JobWorkDetailLineModel dispatchLine;
  final CuttingBatchSummaryModel cuttingCard;
  final double score; // 0.0 to 1.0 match confidence
  final String matchReason;

  CuttingLinkSuggestion({
    required this.dispatch,
    required this.dispatchLine,
    required this.cuttingCard,
    required this.score,
    required this.matchReason,
  });
}

/// Suggestion structure representing a match candidate between a Stitching Receive (O6) and its parent Stitching Dispatch (O5).
class JobInwardLinkSuggestion {
  final JobReceiveModel receive;
  final JobWorkDetailLineModel receiveLine;
  final JobDispatchModel dispatch;
  final JobWorkDetailLineModel dispatchLine;
  final double score;
  final String matchReason;

  JobInwardLinkSuggestion({
    required this.receive,
    required this.receiveLine,
    required this.dispatch,
    required this.dispatchLine,
    required this.score,
    required this.matchReason,
  });
}

/// [PipelineTasksService] — Singleton service running heuristics to smart-link relational transaction records.
class PipelineTasksService {
  static final PipelineTasksService _instance = PipelineTasksService._internal();
  factory PipelineTasksService() => _instance;
  PipelineTasksService._internal();

  final _db = SupabaseService();

  /// Retrieve all unlinked Stitching Dispatch (O5) line items.
  /// Unlinked means the VNO of this dispatch does not exist in any cutting card's `job_card_vnos` array in Supabase.
  Future<List<Map<String, dynamic>>> getUnlinkedDispatchLines() async {
    try {
      // 1. Fetch all cutting card summaries with non-empty job_card_vnos
      final cardsResponse = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('job_card_vnos')
          .not('job_card_vnos', 'is', null);

      final linkedVnos = <int>{};
      for (final row in cardsResponse as List) {
        final list = row['job_card_vnos'] as List?;
        if (list != null) {
          for (final item in list) {
            if (item is num) linkedVnos.add(item.toInt());
          }
        }
      }

      // 2. Fetch O5 dispatches detail rows
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('TYPE', 'O5')
          .limit(200);

      final List<dynamic> linesList = response as List<dynamic>;
      if (linesList.isEmpty) return [];

      final List<int> vnos = linesList.map((e) => (e['VNO'] as num).toInt()).toList();

      // 3. Fetch corresponding headers from sq_BILLS
      final headersResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O5')
          .inFilter('VNO', vnos);

      final List<dynamic> headersList = headersResponse as List<dynamic>;
      final Map<int, Map<String, dynamic>> headersMap = {
        for (var header in headersList) (header['VNO'] as num).toInt(): Map<String, dynamic>.from(header)
      };

      // 4. Merge them and filter out linked ones in Dart
      final List<Map<String, dynamic>> merged = [];
      for (final line in linesList) {
        final vno = (line['VNO'] as num).toInt();
        if (linkedVnos.contains(vno)) continue;

        final header = headersMap[vno];
        if (header != null) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(line);
          item['sq_BILLS'] = header;
          merged.add(item);
        }
      }

      return merged;
    } catch (e) {
      debugPrint('PipelineTasksService.getUnlinkedDispatchLines error: $e');
      return [];
    }
  }

  /// Retrieve all unlinked Stitching Receive (O6) line items where STAGE_VNO is null or 0.
  Future<List<Map<String, dynamic>>> getUnlinkedReceiveLines() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('TYPE', 'O6')
          .or('STAGE_VNO.is.null,STAGE_VNO.eq.0')
          .limit(200);

      final List<dynamic> linesList = response as List<dynamic>;
      if (linesList.isEmpty) return [];

      final List<int> vnos = linesList.map((e) => (e['VNO'] as num).toInt()).toList();

      final headersResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O6')
          .inFilter('VNO', vnos);

      final List<dynamic> headersList = headersResponse as List<dynamic>;
      final Map<int, Map<String, dynamic>> headersMap = {
        for (var header in headersList) (header['VNO'] as num).toInt(): Map<String, dynamic>.from(header)
      };

      final List<Map<String, dynamic>> merged = [];
      for (final line in linesList) {
        final vno = (line['VNO'] as num).toInt();
        final header = headersMap[vno];
        if (header != null) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(line);
          item['sq_BILLS'] = header;
          merged.add(item);
        }
      }

      return merged;
    } catch (e) {
      debugPrint('PipelineTasksService.getUnlinkedReceiveLines error: $e');
      return [];
    }
  }

  /// Runs the "Cutting Link" matching heuristic:
  /// Evaluates unlinked Stitching Dispatches against active Cutting Cards.
  Future<List<CuttingLinkSuggestion>> getCuttingLinkSuggestions() async {
    try {
      // 1. Fetch unlinked dispatches
      final unlinkedRaw = await getUnlinkedDispatchLines();
      if (unlinkedRaw.isEmpty) return [];

      // 2. Fetch recent cutting card summaries
      final cutcardsResponse = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('*')
          .order('CUTDATE', ascending: false)
          .limit(100);

      final List<dynamic> cardsList = cutcardsResponse as List<dynamic>;
      final cuttingCards = cardsList.map((j) => CuttingBatchSummaryModel.fromJson(j)).toList();

      final List<CuttingLinkSuggestion> suggestions = [];

      for (final raw in unlinkedRaw) {
        final line = JobWorkDetailLineModel.fromJson(raw);
        final headerMap = raw['sq_BILLS'] as Map<String, dynamic>;
        final dispatch = JobDispatchModel.fromJson(headerMap);

        // Score against every active cutting card
        for (final cc in cuttingCards) {
          double score = 0.0;
          final List<String> reasons = [];

          // Rule 1: Fabric quality match (substring contains)
          final finishQual = line.quality.toLowerCase();
          final greyQual = cc.greyQual.toLowerCase();
          final isQualMatch = finishQual.contains(greyQual) || greyQual.contains(finishQual);

          if (isQualMatch) {
            score += 0.5;
            reasons.add('Quality match ("${cc.greyQual}" base)');
          }

          // Rule 2: Pieces similarity (within 15% range)
          final double ccPcs = cc.totalFreshPcs.toDouble();
          final double dispPcs = line.pieces;
          if (ccPcs > 0 && dispPcs > 0) {
            final diff = (ccPcs - dispPcs).abs();
            final pctDiff = diff / ccPcs;
            if (pctDiff <= 0.02) {
              score += 0.35;
              reasons.add('Pieces match exactly (${cc.totalFreshPcs} Pcs)');
            } else if (pctDiff <= 0.15) {
              score += 0.20;
              reasons.add('Pieces matching close (${cc.totalFreshPcs} vs ${line.pieces.toInt()} Pcs)');
            }
          }

          // Rule 3: Date proximity (O5 dispatch should be on/after cut date, within 20 days)
          final daysDiff = dispatch.date.difference(cc.cutDate).inDays;
          if (daysDiff >= 0 && daysDiff <= 10) {
            score += 0.15;
            reasons.add('Dispatched $daysDiff days after cutting');
          } else if (daysDiff >= 0 && daysDiff <= 25) {
            score += 0.08;
            reasons.add('Dispatched $daysDiff days after cutting');
          } else if (daysDiff < 0 && daysDiff >= -2) {
            // small buffer for date entry discrepancies
            score += 0.05;
            reasons.add('Cutting date matched ($daysDiff days variance)');
          }

          // Suggest if matching confidence score is high enough (>= 0.45)
          if (score >= 0.45) {
            suggestions.add(CuttingLinkSuggestion(
              dispatch: dispatch,
              dispatchLine: line,
              cuttingCard: cc,
              score: score.clamp(0.0, 1.0),
              matchReason: reasons.join(', '),
            ));
          }
        }
      }

      // Sort by match score descending
      suggestions.sort((a, b) => b.score.compareTo(a.score));
      return suggestions;
    } catch (e) {
      debugPrint('PipelineTasksService.getCuttingLinkSuggestions error: $e');
      return [];
    }
  }

  /// Runs the "Job Inward Link" matching heuristic:
  /// Evaluates unlinked Stitching Receives against corresponding Tailor Dispatches.
  Future<List<JobInwardLinkSuggestion>> getJobInwardSuggestions() async {
    try {
      // 1. Fetch unlinked receives
      final unlinkedRaw = await getUnlinkedReceiveLines();
      if (unlinkedRaw.isEmpty) return [];

      // 2. Fetch recent dispatches
      final dispatchesResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('TYPE', 'O5')
          .order('VNO', ascending: false)
          .limit(100);

      final List<dynamic> dispListRaw = dispatchesResponse as List<dynamic>;
      final List<Map<String, dynamic>> dispList = [];

      if (dispListRaw.isNotEmpty) {
        final List<int> dispVnos = dispListRaw.map((e) => (e['VNO'] as num).toInt()).toList();

        final dispHeadersResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLS')
            .select('*')
            .eq('TYPE', 'O5')
            .inFilter('VNO', dispVnos);

        final List<dynamic> dispHeadersList = dispHeadersResponse as List<dynamic>;
        final Map<int, Map<String, dynamic>> dispHeadersMap = {
          for (var header in dispHeadersList) (header['VNO'] as num).toInt(): Map<String, dynamic>.from(header)
        };

        for (final line in dispListRaw) {
          final vno = (line['VNO'] as num).toInt();
          final header = dispHeadersMap[vno];
          if (header != null) {
            final Map<String, dynamic> item = Map<String, dynamic>.from(line);
            item['sq_BILLS'] = header;
            dispList.add(item);
          }
        }
      }

      final List<JobInwardLinkSuggestion> suggestions = [];

      for (final raw in unlinkedRaw) {
        final line = JobWorkDetailLineModel.fromJson(raw);
        final headerMap = raw['sq_BILLS'] as Map<String, dynamic>;
        final receive = JobReceiveModel.fromJson(headerMap);

        for (final dispRaw in dispList) {
          final dispLine = JobWorkDetailLineModel.fromJson(dispRaw);
          final dispHeaderMap = dispRaw['sq_BILLS'] as Map<String, dynamic>;
          final dispatch = JobDispatchModel.fromJson(dispHeaderMap);

          // Heuristic Rule 1: Same Tailor/Vendor Code
          if (receive.tailorCode != dispatch.tailorCode) continue;

          double score = 0.0;
          final List<String> reasons = [];

          // Heuristic Rule 2: Quality Match
          if (line.quality.trim().toLowerCase() == dispLine.quality.trim().toLowerCase()) {
            score += 0.50;
            reasons.add('Same fabric quality ("${line.quality}")');
          }

          // Heuristic Rule 3: Return pieces balance matching issue pieces
          final double recPcs = line.pieces;
          final double dispPcs = dispLine.pieces;
          if (recPcs == dispPcs) {
            score += 0.35;
            reasons.add('Pieces returned match dispatched exactly (${recPcs.toInt()} Pcs)');
          } else if ((recPcs - dispPcs).abs() <= 10) {
            score += 0.15;
            reasons.add('Pieces returned close (${recPcs.toInt()} vs ${dispPcs.toInt()} Pcs)');
          }

          // Heuristic Rule 4: Dates matching (receive must be on/after dispatch date, within 45 days)
          final daysDiff = receive.date.difference(dispatch.date).inDays;
          if (daysDiff >= 0 && daysDiff <= 15) {
            score += 0.15;
            reasons.add('Returned $daysDiff days after dispatch');
          } else if (daysDiff >= 0 && daysDiff <= 45) {
            score += 0.08;
            reasons.add('Returned $daysDiff days after dispatch');
          }

          if (score >= 0.50) {
            suggestions.add(JobInwardLinkSuggestion(
              receive: receive,
              receiveLine: line,
              dispatch: dispatch,
              dispatchLine: dispLine,
              score: score.clamp(0.0, 1.0),
              matchReason: reasons.join(', '),
            ));
          }
        }
      }

      suggestions.sort((a, b) => b.score.compareTo(a.score));
      return suggestions;
    } catch (e) {
      debugPrint('PipelineTasksService.getJobInwardSuggestions error: $e');
      return [];
    }
  }

  /// Perform structural linkage linking a Stitching Dispatch (O5) line to a Cutting Card (O3).
  Future<bool> linkDispatchToCuttingCard({
    required int dispatchVno,
    required int cuttingCardNo,
  }) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .rpc('link_job_to_cutting', params: {
            'p_cutting_vno': cuttingCardNo,
            'p_job_vno': dispatchVno,
          });

      return true;
    } catch (e) {
      debugPrint('PipelineTasksService.linkDispatchToCuttingCard error: $e');
      return false;
    }
  }

  /// Perform structural linkage linking a Stitching Receive (O6) line to a parent Stitching Dispatch (O5).
  Future<bool> linkReceiveToDispatch({
    required int receiveVno,
    required int dispatchVno,
  }) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .update({
            'STAGE_VNO': dispatchVno,
            'STAGE_TYPE': 'O5',
          })
          .eq('VNO', receiveVno)
          .eq('TYPE', 'O6');

      return true;
    } catch (e) {
      debugPrint('PipelineTasksService.linkReceiveToDispatch error: $e');
      return false;
    }
  }
}
