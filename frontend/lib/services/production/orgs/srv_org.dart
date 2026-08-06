/*
================================================================================
LLM CONTEXT & QUERY SPACE — ORGANIZATIONS MODULE SERVICE (srv_org.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Organizations / Party Master (`org` / Master Layer).
   - Manages data access and filtering across Supabase table `IMMBE2627.sq_MASTER` (5,502 parties).
   - Handles search queries, ATYPE filters, city filters, broker filters, and submodule barrel filters.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Submodule ATYPE Filtering:
     - `OrgCategory.all`: Fetches all parties.
     - `OrgCategory.debtors`: `ATYPE = 1` (2,703 Customers).
     - `OrgCategory.greySuppliers`: `ATYPE = 2` (772 Grey Suppliers).
     - `OrgCategory.jobWorkers`: `ATYPE IN (14, 119)` (343 Dyeing & Embroidery Units).
     - `OrgCategory.brokers`: `ATYPE = 12` (496 Brokers).
     - `OrgCategory.others`: `ATYPE NOT IN (1, 2, 12, 14, 119)` (488 Overheads/Staff/Goods Suppliers).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` is Airbyte-managed read-only mirror.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_master.dart';
import '../../../models/production/orgs/mdl_org.dart';
import '../../core/service_supabase.dart';

/// [SrvOrg] — Module Service Singleton for Organizations Master Operations.
class SrvOrg {
  static final SrvOrg _instance = SrvOrg._internal();
  factory SrvOrg() => _instance;
  SrvOrg._internal();

  final _db = SupabaseService();

  /// Fetches paginated Organization headers for [category] with optional context filters.
  Future<({List<MdlOrgHeader> data, int totalCount})> getOrganizations({
    required OrgCategory category,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    Set<String> selectedCities = const {},
    Set<String> selectedBrokers = const {},
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code');

      // Submodule ATYPE filter
      switch (category) {
        case OrgCategory.debtors:
          countQuery = countQuery.eq('ATYPE', 1);
          break;
        case OrgCategory.greySuppliers:
          countQuery = countQuery.eq('ATYPE', 2);
          break;
        case OrgCategory.jobWorkers:
          countQuery = countQuery.inFilter('ATYPE', [14, 119]);
          break;
        case OrgCategory.brokers:
          countQuery = countQuery.eq('ATYPE', 12);
          break;
        case OrgCategory.others:
          countQuery = countQuery.not('ATYPE', 'in', '(1, 2, 12, 14, 119)');
          break;
        case OrgCategory.all:
          break;
      }

      if (selectedCities.isNotEmpty) {
        countQuery = countQuery.inFilter('CITY1', selectedCities.toList());
      }
      if (selectedBrokers.isNotEmpty) {
        countQuery = countQuery.inFilter('ADATIYA', selectedBrokers.toList());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        countQuery = countQuery.or('code.ilike.$q,NAME.ilike.$q,CITY1.ilike.$q,STATION.ilike.$q,GSTIN.ilike.$q,MOBILE.ilike.$q');
      }

      final countRes = await countQuery.count();
      final int totalCount = countRes.count ?? 0;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('*');

      // Submodule ATYPE filter
      switch (category) {
        case OrgCategory.debtors:
          fetchQuery = fetchQuery.eq('ATYPE', 1);
          break;
        case OrgCategory.greySuppliers:
          fetchQuery = fetchQuery.eq('ATYPE', 2);
          break;
        case OrgCategory.jobWorkers:
          fetchQuery = fetchQuery.inFilter('ATYPE', [14, 119]);
          break;
        case OrgCategory.brokers:
          fetchQuery = fetchQuery.eq('ATYPE', 12);
          break;
        case OrgCategory.others:
          fetchQuery = fetchQuery.not('ATYPE', 'in', '(1, 2, 12, 14, 119)');
          break;
        case OrgCategory.all:
          break;
      }

      if (selectedCities.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('CITY1', selectedCities.toList());
      }
      if (selectedBrokers.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('ADATIYA', selectedBrokers.toList());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        fetchQuery = fetchQuery.or('code.ilike.$q,NAME.ilike.$q,CITY1.ilike.$q,STATION.ilike.$q,GSTIN.ilike.$q,MOBILE.ilike.$q');
      }

      fetchQuery = fetchQuery.order('code', ascending: true);

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final rawList = response as List<dynamic>? ?? [];

      final items = rawList
          .map((j) => MdlOrgHeader(core: SqMasterModel.fromJson(j as Map<String, dynamic>)))
          .toList();

      return (data: items, totalCount: totalCount);
    } catch (e, stack) {
      debugPrint('Error in SrvOrg.getOrganizations: $e\n$stack');
      return (data: <MdlOrgHeader>[], totalCount: 0);
    }
  }

  /// Distinct Cities (`CITY1`)
  Future<List<String>> getCityOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('CITY1')
          .not('CITY1', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final city = (row['CITY1'] as String?)?.trim();
        if (city != null && city.isNotEmpty) {
          set.add(city);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvOrg.getCityOptions: $e');
      return [];
    }
  }

  /// Distinct Brokers / Agents (`ADATIYA`)
  Future<List<String>> getBrokerOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('ADATIYA')
          .not('ADATIYA', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final broker = (row['ADATIYA'] as String?)?.trim();
        if (broker != null && broker.isNotEmpty) {
          set.add(broker);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvOrg.getBrokerOptions: $e');
      return [];
    }
  }
}
