/*
================================================================================
LLM CONTEXT & QUERY SPACE — MODERN ITEM MASTER SERVICE (srv_sb_item.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Singleton Data Access Service for `IMMBE2627.sb_item`,
     `IMMBE2627.sb_item_group_config`, and `IMMBE2627.sb_item_audit_log`.
   - Orchestrates the "Clean-As-You-Go" item onboarding workflow, historical
     variation/rate discovery from `sq_BILLDET`/`sq_PINVTRN`, and Admin barrel
     schema management.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `discoverLegacyBillInsights`: Inspects historical purchase lines in
     `sq_BILLDET` and `sq_PINVTRN` for a chosen `sq_QUAL` item to auto-discover
     variations (from `CATEGORY` / `DETAILS`, such as carton ply/dimensions or
     foam sizes) and historical purchase rates.
   - `saveSbItem`: Writes to `IMMBE2627.sb_item` and records field-level diffs
     (`cost_price`, `sell_price_1`, `hsn_code`, `variations`, `domain_specs`)
     into `IMMBE2627.sb_item_audit_log` with user attribution and reason.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_QUAL`, `sq_BILLDET`, and `sq_PINVTRN` are strictly read-only Airbyte
     mirrors. All writes target `sb_item`, `sb_item_group_config`, and
     `sb_item_audit_log`.
================================================================================
*/

library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_qual.dart';
import '../../../models/masters/items/mdl_sb_item.dart';
import '../../core/service_supabase.dart';

/// [LegacyBillDiscovery] — Auto-discovered historical purchase intelligence
/// for a legacy `sq_QUAL` item.
@immutable
class LegacyBillDiscovery {
  final double avgPurchaseRate;
  final int totalHistoricalBills;
  final String? topHsnFromBills;
  final List<SbItemVariation> discoveredVariations;

  const LegacyBillDiscovery({
    this.avgPurchaseRate = 0.0,
    this.totalHistoricalBills = 0,
    this.topHsnFromBills,
    this.discoveredVariations = const [],
  });
}

/// [SrvSbItem] — Singleton Service for Modern Item Master & Admin Config.
class SrvSbItem {
  static final SrvSbItem _instance = SrvSbItem._internal();
  factory SrvSbItem() => _instance;
  SrvSbItem._internal();

  final _db = SupabaseService();

  // ---------------------------------------------------------------------------
  // 1. ADMIN ITEM GROUP (BARREL) CONFIGURATION
  // ---------------------------------------------------------------------------

  /// Fetches all barrel configurations from `IMMBE2627.sb_item_group_config`.
  Future<List<SbItemGroupConfig>> getGroupConfigs({
    bool activeOnly = true,
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_item_group_config')
          .select('*');

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final res = await query.order('sort_order', ascending: true);
      final list = res as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(SbItemGroupConfig.fromJson)
          .toList();
    } catch (e, stack) {
      debugPrint('Error in SrvSbItem.getGroupConfigs: $e\n$stack');
      return const [];
    }
  }

  /// Creates or updates an Admin Barrel Blueprint in `sb_item_group_config`.
  Future<({bool success, String? error})> upsertGroupConfig(
    SbItemGroupConfig config,
  ) async {
    try {
      final payload = {
        ...config.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _db.client
          .schema('IMMBE2627')
          .from('sb_item_group_config')
          .upsert(payload, onConflict: 'group_code');

      return (success: true, error: null);
    } catch (e) {
      debugPrint('Error in SrvSbItem.upsertGroupConfig: $e');
      return (success: false, error: _db.handleDbError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // 2. MODERN ITEM MASTER (`sb_item`) QUERIES & LEGACY LOOKUPS
  // ---------------------------------------------------------------------------

  /// Fetches all items in `IMMBE2627.sb_item`.
  Future<List<MdlSbItem>> getSbItems({
    String? itemGroup,
    String? searchQuery,
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_item')
          .select('*');

      if (itemGroup != null && itemGroup.isNotEmpty && itemGroup != 'ALL') {
        query = query.eq('item_group', itemGroup);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        query = query.or(
          'item_code.ilike.$q,name.ilike.$q,legacy_qcode.ilike.$q,hsn_code.ilike.$q',
        );
      }

      final res = await query.order('updated_at', ascending: false);
      final list = res as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(MdlSbItem.fromJson)
          .toList();
    } catch (e, stack) {
      debugPrint('Error in SrvSbItem.getSbItems: $e\n$stack');
      return const [];
    }
  }

  /// Returns a lookup map of upgraded `MdlSbItem` keyed by both `legacy_qcode`
  /// and `item_code` so the Items Landing Table can display live completion
  /// badges next to legacy items.
  Future<Map<String, MdlSbItem>> getUpgradedLookupMap() async {
    final items = await getSbItems();
    final Map<String, MdlSbItem> map = {};
    for (final item in items) {
      map[item.itemCode.toUpperCase()] = item;
      if (item.legacyQcode != null && item.legacyQcode!.isNotEmpty) {
        map[item.legacyQcode!.toUpperCase()] = item;
      }
    }
    return map;
  }

  /// Searches legacy `IMMBE2627.sq_QUAL` for the Add/Upgrade Item Modal.
  Future<List<SqQualModel>> searchLegacyQual(String query, {int limit = 25}) async {
    try {
      dynamic req = _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('*');

      if (query.trim().isNotEmpty) {
        final q = '%${query.trim()}%';
        req = req.or('qcode.ilike.$q,NAME.ilike.$q,category.ilike.$q,HSN_CODE.ilike.$q');
      }

      final res = await req.order('NAME', ascending: true).limit(limit);
      final list = res as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(SqQualModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('Error in SrvSbItem.searchLegacyQual: $e');
      return const [];
    }
  }

  /// Inspects historical `sq_BILLDET` and `sq_PINVTRN` rows for [qcode] to
  /// auto-discover historical purchase rates and variations (e.g. Carton
  /// `35.25*15*30 7 PLY` in `CATEGORY` or Foam `65*15` in `DETAILS`).
  Future<LegacyBillDiscovery> discoverLegacyBillInsights(String qcode) async {
    try {
      final clean = qcode.trim();
      if (clean.isEmpty) return const LegacyBillDiscovery();

      // 1. Check sq_BILLDET (Purchase & Jobwork series)
      final detRes = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('TYPE, RATE, HSN_CODE, CATEGORY, DETAILS')
          .eq('qual', clean)
          .neq('TYPE', 'S1')
          .limit(300);

      final detList = detRes as List<dynamic>? ?? [];

      double rateSum = 0.0;
      int rateCount = 0;
      final Map<String, int> hsnFreq = {};
      final Map<String, List<double>> variationRates = {};

      for (final raw in detList.whereType<Map<String, dynamic>>()) {
        final double r = (raw['RATE'] is num)
            ? (raw['RATE'] as num).toDouble()
            : double.tryParse(raw['RATE']?.toString() ?? '0') ?? 0.0;
        if (r > 0) {
          rateSum += r;
          rateCount++;
        }

        final String hsn = (raw['HSN_CODE'] ?? '').toString().trim();
        if (hsn.isNotEmpty && hsn != '-') {
          hsnFreq[hsn] = (hsnFreq[hsn] ?? 0) + 1;
        }

        final String cat = (raw['CATEGORY'] ?? '').toString().trim();
        final String det = (raw['DETAILS'] ?? '').toString().trim();
        final String varTag = det.isNotEmpty
            ? det
            : (cat.isNotEmpty &&
                    cat != 'SAREES' &&
                    cat != 'PACKING' &&
                    cat != 'PLAIN (FINAL)'
                ? cat
                : '');
        if (varTag.isNotEmpty) {
          variationRates.putIfAbsent(varTag, () => []);
          if (r > 0) variationRates[varTag]!.add(r);
        }
      }

      // 2. If no sq_BILLDET rows found, check sq_PINVTRN (P1 Grey Purchase)
      if (rateCount == 0) {
        final pinvRes = await _db.client
            .schema('IMMBE2627')
            .from('sq_PINVTRN')
            .select('PURRATE, RATE')
            .eq('QUAL', clean)
            .limit(150);

        final pinvList = pinvRes as List<dynamic>? ?? [];
        for (final raw in pinvList.whereType<Map<String, dynamic>>()) {
          final double pr = (raw['PURRATE'] is num)
              ? (raw['PURRATE'] as num).toDouble()
              : double.tryParse(raw['PURRATE']?.toString() ?? '0') ?? 0.0;
          final double r = pr > 0
              ? pr
              : ((raw['RATE'] is num)
                  ? (raw['RATE'] as num).toDouble()
                  : double.tryParse(raw['RATE']?.toString() ?? '0') ?? 0.0);
          if (r > 0) {
            rateSum += r;
            rateCount++;
          }
        }
      }

      String? bestHsn;
      int maxFreq = 0;
      hsnFreq.forEach((k, v) {
        if (v > maxFreq) {
          maxFreq = v;
          bestHsn = k;
        }
      });

      final List<SbItemVariation> vars = [];
      int idx = 1;
      variationRates.forEach((tag, rates) {
        if (vars.length < 12) {
          final double avgVarRate = rates.isNotEmpty
              ? double.parse(
                  (rates.reduce((a, b) => a + b) / rates.length)
                      .toStringAsFixed(2),
                )
              : 0.0;
          vars.add(SbItemVariation(
            code: '${clean.replaceAll(' ', '')}-V$idx',
            name: tag,
            specs: {'dimensions': tag},
            costPrice: avgVarRate,
            lastPurRate: rates.isNotEmpty ? rates.first : 0.0,
            reorderLevel: 50,
          ));
          idx++;
        }
      });

      final double avgRate = rateCount > 0
          ? double.parse((rateSum / rateCount).toStringAsFixed(2))
          : 0.0;

      return LegacyBillDiscovery(
        avgPurchaseRate: avgRate,
        totalHistoricalBills: detList.length,
        topHsnFromBills: bestHsn,
        discoveredVariations: vars,
      );
    } catch (e) {
      debugPrint('Error in SrvSbItem.discoverLegacyBillInsights: $e');
      return const LegacyBillDiscovery();
    }
  }

  // ---------------------------------------------------------------------------
  // 3. TRANSACTIONAL SAVE + IMMUTABLE AUDIT LOGGING
  // ---------------------------------------------------------------------------

  /// Saves or updates an item in `IMMBE2627.sb_item` and writes immutable
  /// audit records to `IMMBE2627.sb_item_audit_log`.
  Future<({bool success, MdlSbItem? savedItem, String? error})> saveSbItem({
    required MdlSbItem item,
    required int calculatedCompScore,
    required String reasonComment,
    MdlSbItem? previousItem,
  }) async {
    try {
      final int nextVersion =
          previousItem != null ? (previousItem.version + 1) : 1;
      final payload = item
          .copyWith(compScore: calculatedCompScore, version: nextVersion)
          .toJson(overrideCompScore: calculatedCompScore);

      final res = await _db.client
          .schema('IMMBE2627')
          .from('sb_item')
          .upsert(payload, onConflict: 'item_code')
          .select('*')
          .single();

      final saved = MdlSbItem.fromJson(res);
      final String itemId = saved.id ?? '';

      if (itemId.isNotEmpty) {
        final List<Map<String, dynamic>> auditRows = [];
        final String cleanReason = reasonComment.trim().isNotEmpty
            ? reasonComment.trim()
            : (previousItem == null
                ? 'Initial Clean-As-You-Go item onboarding'
                : 'Item specification update');

        if (previousItem == null) {
          auditRows.add({
            'item_id': itemId,
            'change_type': 'INITIAL_ONBOARDING',
            'field_name': 'comp_score',
            'old_value': item.legacyQcode != null
                ? 'Legacy sq_QUAL (${item.legacyQcode})'
                : 'New Standalone Item',
            'new_value':
                'Upgraded to ${saved.itemGroup} (Score: $calculatedCompScore%)',
            'reason_comment': cleanReason,
            'changed_by_user_name': 'ERP Operator',
          });
        } else {
          if (previousItem.costPrice != saved.costPrice) {
            auditRows.add({
              'item_id': itemId,
              'change_type': 'PRICE_REVISION',
              'field_name': 'cost_price',
              'old_value': previousItem.costPrice.toStringAsFixed(2),
              'new_value': saved.costPrice.toStringAsFixed(2),
              'reason_comment': cleanReason,
              'changed_by_user_name': 'ERP Operator',
            });
          }
          if (previousItem.sellPrice1 != saved.sellPrice1) {
            auditRows.add({
              'item_id': itemId,
              'change_type': 'PRICE_REVISION',
              'field_name': 'sell_price_1',
              'old_value': previousItem.sellPrice1.toStringAsFixed(2),
              'new_value': saved.sellPrice1.toStringAsFixed(2),
              'reason_comment': cleanReason,
              'changed_by_user_name': 'ERP Operator',
            });
          }
          if (previousItem.hsnCode != saved.hsnCode ||
              previousItem.gstRate != saved.gstRate) {
            auditRows.add({
              'item_id': itemId,
              'change_type': 'TAX_UPDATE',
              'field_name': 'hsn_code / gst_rate',
              'old_value':
                  '${previousItem.hsnCode} (${previousItem.gstRate}%)',
              'new_value': '${saved.hsnCode} (${saved.gstRate}%)',
              'reason_comment': cleanReason,
              'changed_by_user_name': 'ERP Operator',
            });
          }
          if (previousItem.variations.length != saved.variations.length ||
              jsonEncode(previousItem.domainSpecs) !=
                  jsonEncode(saved.domainSpecs)) {
            auditRows.add({
              'item_id': itemId,
              'change_type': 'SPEC_UPDATE',
              'field_name': 'domain_specs / variations',
              'old_value':
                  '${previousItem.variations.length} vars • Score ${previousItem.compScore}%',
              'new_value':
                  '${saved.variations.length} vars • Score ${saved.compScore}%',
              'reason_comment': cleanReason,
              'changed_by_user_name': 'ERP Operator',
            });
          }
        }

        if (auditRows.isNotEmpty) {
          await _db.client
              .schema('IMMBE2627')
              .from('sb_item_audit_log')
              .insert(auditRows);
        }
      }

      return (success: true, savedItem: saved, error: null);
    } catch (e, stack) {
      debugPrint('Error in SrvSbItem.saveSbItem: $e\n$stack');
      return (success: false, savedItem: null, error: _db.handleDbError(e));
    }
  }

  /// Fetches immutable audit trail logs for [itemId].
  Future<List<MdlSbItemAuditLog>> getItemAuditLogs(String itemId) async {
    try {
      final res = await _db.client
          .schema('IMMBE2627')
          .from('sb_item_audit_log')
          .select('*')
          .eq('item_id', itemId)
          .order('created_at', ascending: false)
          .limit(30);

      final list = res as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(MdlSbItemAuditLog.fromJson)
          .toList();
    } catch (e) {
      debugPrint('Error in SrvSbItem.getItemAuditLogs: $e');
      return const [];
    }
  }
}

