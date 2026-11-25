/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK ANALYTICS SYNTHESIZER (scr_jw_analytics.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - In-memory telemetry, trend aggregation, aging bucket calculation, and Party/Fabric
     pivot engine for Job Work Operations (`scr_jw_landing.dart`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Pendency rule: `h.isPending` (`CLOSED IS NULL OR '' OR 'N'`); overdue threshold > 15 days.
   - Maps SLA buckets directly to `DyColorSystem.chartPalette` semantic tokens:
     * `0-7d Active`  -> index `3` (`cyan500`)
     * `8-15d Aging`  -> index `1` (`orange500`)
     * `Overdue >15d` -> index `0` (`red500`)
     * `Completed`    -> index `2` (`emerald500`)

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Null-safe date arithmetic and 0-denominator guards throughout.
   - Computes entirely from already-fetched `MdlJwHeader` records (`sq_BILLS` + `sq_BILLDET`).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Server-side SQL views (`vwsq_`) can later supply cross-page fiscal totals above `limit=100`.
================================================================================
*/

library;

import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../../../dynamic_ai/micro/charts/dy_donut_breakdown_card.dart';
import '../../../dynamic_ai/micro/charts/dy_trend_area_chart.dart';
import '../../../models/pipeline/mdl_jw.dart';

/// Fiscal/time scope preset for Job Work landing snapshot.
enum JwDateScope {
  allFy,
  days90,
  days30;

  String get label {
    switch (this) {
      case JwDateScope.allFy:
        return 'All FY';
      case JwDateScope.days90:
        return 'Last 90D';
      case JwDateScope.days30:
        return 'Last 30D';
    }
  }

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case JwDateScope.allFy:
        return null;
      case JwDateScope.days90:
        return now.subtract(const Duration(days: 90));
      case JwDateScope.days30:
        return now.subtract(const Duration(days: 30));
    }
  }
}

/// Aggregated party or fabric pivot row computed from live [MdlJwHeader] entries.
class JwPivotSummaryRow {
  final String label;
  final int challanCount;
  final int pendingCount;
  final int totalPieces;
  final double totalMeters;
  final double totalAmount;

  const JwPivotSummaryRow({
    required this.label,
    required this.challanCount,
    required this.pendingCount,
    required this.totalPieces,
    required this.totalMeters,
    required this.totalAmount,
  });

  double get pendingPct =>
      challanCount == 0 ? 0.0 : (pendingCount / challanCount) * 100.0;
}

/// In-memory telemetry snapshot powering all Bento cards for Job Work.
class JwAnalyticsSnapshot {
  final int totalChallans;
  final int pendingChallans;
  final int overdueChallans;
  final int completedChallans;
  final int totalPieces;
  final int pendingPieces;
  final double totalMeters;
  final double netAmount;
  final List<double> piecesSparkline;
  final List<double> pendingSparkline;
  final List<double> amountSparkline;
  final List<DyTrendPoint> trendPoints;
  final List<MdlJwHeader> urgentTasks;
  final List<JwPivotSummaryRow> partyPivot;
  final List<JwPivotSummaryRow> qualityPivot;
  final List<DyDonutSlice> agingSlices;

  const JwAnalyticsSnapshot({
    required this.totalChallans,
    required this.pendingChallans,
    required this.overdueChallans,
    required this.completedChallans,
    required this.totalPieces,
    required this.pendingPieces,
    required this.totalMeters,
    required this.netAmount,
    required this.piecesSparkline,
    required this.pendingSparkline,
    required this.amountSparkline,
    required this.trendPoints,
    required this.urgentTasks,
    required this.partyPivot,
    required this.qualityPivot,
    required this.agingSlices,
  });

  double get completionRatio =>
      totalChallans == 0 ? 0.0 : completedChallans / totalChallans;

  static int ageDaysOf(MdlJwHeader header) {
    final dt = header.date;
    if (dt == null) return 0;
    return math.max(0, DateTime.now().difference(dt).inDays);
  }

  static String formatCompactInr(double val) {
    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(2)}Cr';
    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(2)}L';
    if (val >= 1000) return '₹${(val / 1000).toStringAsFixed(1)}k';
    return '₹${val.toStringAsFixed(0)}';
  }

  static String formatCompactInt(int val) =>
      NumberFormat.decimalPattern('en_IN').format(val);

  factory JwAnalyticsSnapshot.fromHeaders(
    List<MdlJwHeader> headers, {
    int metricMode = 0, // 0: Pieces, 1: Meters, 2: Amount (₹)
  }) {
    int pendingCount = 0;
    int overdueCount = 0;
    int completedCount = 0;
    int totalPcs = 0;
    int pendingPcs = 0;
    double totalMts = 0.0;
    double totalAmt = 0.0;

    final Map<String, ({int pcs, double mtrs, double amt, int pendingPcs, int count})>
        monthlyBuckets = {};
    final Map<String, _PivotAccumulator> partyAcc = {};
    final Map<String, _PivotAccumulator> qualAcc = {};
    final List<MdlJwHeader> pendingList = [];

    int age0to7 = 0;
    int age8to15 = 0;
    int ageOver15 = 0;
    int closedSlice = 0;

    for (final h in headers) {
      totalPcs += h.totalPieces;
      totalMts += h.totalMeters;
      totalAmt += h.netAmount;

      final age = ageDaysOf(h);
      if (h.isPending) {
        pendingCount++;
        pendingPcs += h.totalPieces;
        pendingList.add(h);
        if (age > 15) {
          overdueCount++;
          ageOver15++;
        } else if (age > 7) {
          age8to15++;
        } else {
          age0to7++;
        }
      } else {
        completedCount++;
        closedSlice++;
      }

      final dt = h.date;
      final bucketKey = dt != null
          ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}'
          : 'Unknown';
      final prev = monthlyBuckets[bucketKey] ??
          (pcs: 0, mtrs: 0.0, amt: 0.0, pendingPcs: 0, count: 0);
      monthlyBuckets[bucketKey] = (
        pcs: prev.pcs + h.totalPieces,
        mtrs: prev.mtrs + h.totalMeters,
        amt: prev.amt + h.netAmount,
        pendingPcs: prev.pendingPcs + (h.isPending ? h.totalPieces : 0),
        count: prev.count + 1,
      );

      final pKey = h.partyName.isNotEmpty ? h.partyName : 'Unknown Party';
      partyAcc.putIfAbsent(pKey, () => _PivotAccumulator()).add(h);

      final qKey = h.quality.isNotEmpty ? h.quality : 'N/A';
      qualAcc.putIfAbsent(qKey, () => _PivotAccumulator()).add(h);
    }

    final sortedKeys = monthlyBuckets.keys.toList()..sort();
    final List<double> pcsSpark = [];
    final List<double> pendSpark = [];
    final List<double> amtSpark = [];
    final List<DyTrendPoint> trendPts = [];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (final key in sortedKeys) {
      final b = monthlyBuckets[key]!;
      pcsSpark.add(b.pcs.toDouble());
      pendSpark.add(b.pendingPcs.toDouble());
      amtSpark.add(b.amt);

      String label = key;
      final parts = key.split('-');
      if (parts.length == 2) {
        final m = int.tryParse(parts[1]) ?? 1;
        final yr = parts[0].length >= 4 ? parts[0].substring(2) : parts[0];
        label = "${monthNames[(m - 1).clamp(0, 11)]} '$yr";
      }

      double primary;
      double? secondary;
      if (metricMode == 1) {
        primary = b.mtrs;
        secondary =
            b.pendingPcs > 0 ? b.mtrs * (b.pendingPcs / math.max(1, b.pcs)) : 0;
      } else if (metricMode == 2) {
        primary = b.amt;
        secondary = null;
      } else {
        primary = b.pcs.toDouble();
        secondary = b.pendingPcs.toDouble();
      }

      trendPts.add(
        DyTrendPoint(
          label: label,
          primaryValue: primary,
          secondaryValue: secondary,
          tooltipExtra: '${b.count} challans',
        ),
      );
    }

    pendingList.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return b.vno.compareTo(a.vno);
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

    final partyRows = _toSortedPivot(partyAcc);
    final qualRows = _toSortedPivot(qualAcc);

    final slices = <DyDonutSlice>[
      if (age0to7 > 0)
        DyDonutSlice(
          label: '0-7d Active',
          value: age0to7.toDouble(),
          formattedValue: '$age0to7 lots',
          paletteIndex: 3, // cyan500
        ),
      if (age8to15 > 0)
        DyDonutSlice(
          label: '8-15d Aging',
          value: age8to15.toDouble(),
          formattedValue: '$age8to15 lots',
          paletteIndex: 1, // orange500
        ),
      if (ageOver15 > 0)
        DyDonutSlice(
          label: 'Overdue >15d',
          value: ageOver15.toDouble(),
          formattedValue: '$ageOver15 lots',
          paletteIndex: 0, // red500
        ),
      if (closedSlice > 0)
        DyDonutSlice(
          label: 'Completed',
          value: closedSlice.toDouble(),
          formattedValue: '$closedSlice lots',
          paletteIndex: 2, // emerald500
        ),
    ];

    return JwAnalyticsSnapshot(
      totalChallans: headers.length,
      pendingChallans: pendingCount,
      overdueChallans: overdueCount,
      completedChallans: completedCount,
      totalPieces: totalPcs,
      pendingPieces: pendingPcs,
      totalMeters: totalMts,
      netAmount: totalAmt,
      piecesSparkline: pcsSpark,
      pendingSparkline: pendSpark,
      amountSparkline: amtSpark,
      trendPoints: trendPts,
      urgentTasks: pendingList,
      partyPivot: partyRows,
      qualityPivot: qualRows,
      agingSlices: slices,
    );
  }

  static List<JwPivotSummaryRow> _toSortedPivot(
    Map<String, _PivotAccumulator> acc,
  ) {
    final rows = acc.entries
        .map(
          (e) => JwPivotSummaryRow(
            label: e.key,
            challanCount: e.value.count,
            pendingCount: e.value.pendingCount,
            totalPieces: e.value.pieces,
            totalMeters: e.value.meters,
            totalAmount: e.value.amount,
          ),
        )
        .toList();
    rows.sort((a, b) => b.totalPieces.compareTo(a.totalPieces));
    return rows;
  }
}

class _PivotAccumulator {
  int count = 0;
  int pendingCount = 0;
  int pieces = 0;
  double meters = 0.0;
  double amount = 0.0;

  void add(MdlJwHeader h) {
    count++;
    if (h.isPending) pendingCount++;
    pieces += h.totalPieces;
    meters += h.totalMeters;
    amount += h.netAmount;
  }
}
