/*
================================================================================
LLM CONTEXT & QUERY SPACE — ORGANIZATIONS MODULE DATA MODELS (mdl_org.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Organizations / Party Master (`org` / Master Layer).
   - Wraps canonical `SqMasterModel` instances from table `IMMBE2627.sq_MASTER` (5,502 parties).
   - Maps database columns to 3-tiered table structures (`DyTable`) and categorizes party ledgers into 6 functional barrels based on `ATYPE`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Submodule Categorization (`OrgCategory`):
     - `all`: All 5,502 party ledger records.
     - `debtors`: Customers / Wholesale & Retail Buyers (`ATYPE = 1`, 2,703 records).
     - `greySuppliers`: Raw Fabric Weavers & Grey Suppliers (`ATYPE = 2`, 772 records).
     - `jobWorkers`: Dyeing Mills & Embroidery Units (`ATYPE IN (14, 119)`, 343 records).
     - `brokers`: Commission Agents & Brokers (`ATYPE = 12`, 496 records).
     - `others`: Overheads, General Suppliers, Staff (`ATYPE NOT IN (1, 2, 12, 14, 119)`, 488 records).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` is Airbyte-managed read-only mirror.
   - `MOBILE` is primary contact field for WhatsApp dispatch notifications.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../core/sq/sq_master.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';

/// Functional Submodule Categories for Organizations Master
enum OrgCategory {
  all,
  debtors,
  greySuppliers,
  jobWorkers,
  brokers,
  others;

  String get displayName {
    switch (this) {
      case OrgCategory.all:
        return 'All Orgs';
      case OrgCategory.debtors:
        return 'Customers / Debtors';
      case OrgCategory.greySuppliers:
        return 'Grey Suppliers';
      case OrgCategory.jobWorkers:
        return 'Job Workers & Mills';
      case OrgCategory.brokers:
        return 'Brokers & Agents';
      case OrgCategory.others:
        return 'Others & Expenses';
    }
  }

  IconData get icon {
    switch (this) {
      case OrgCategory.all:
        return shad.LucideIcons.building;
      case OrgCategory.debtors:
        return shad.LucideIcons.users;
      case OrgCategory.greySuppliers:
        return shad.LucideIcons.factory;
      case OrgCategory.jobWorkers:
        return shad.LucideIcons.scissors;
      case OrgCategory.brokers:
        return shad.LucideIcons.userCheck;
      case OrgCategory.others:
        return shad.LucideIcons.receipt;
    }
  }
}

/// [MdlOrgHeader] — Primary Domain Model for Organization Row Representation
@immutable
class MdlOrgHeader {
  final SqMasterModel core;

  const MdlOrgHeader({required this.core});

  String get code => core.code;
  String get name => core.name;
  int get atype => core.atype;
  String get atypeDescription => core.atypeDescription;
  String get city => core.city1;
  String get station => core.station;
  String get broker => core.adatiya;
  String get mobile => core.mobile;
  String get gstin => core.gstin;
  String get fullAddress => core.fullAddress;

  bool get isCustomer => core.isCustomer;
  bool get isGreySupplier => core.isGreySupplier;
  bool get isBroker => core.isBroker;
  bool get isJobWorker => core.isJobWorker;

  /// Convert into a Tier 2 Document Header Row for [DyTable]
  DyTableRowData toDyDefRowData() {
    return DyTableRowData(
      id: code,
      rowType: DyTableRowType.def,
      voucherNo: code,
      partyName: name,
      designPattern: atypeDescription,
      quantity: city.isNotEmpty ? city : 'Local',
      amount: mobile.isNotEmpty ? mobile : '-',
      amountValue: 0.0,
      status: gstin.isNotEmpty ? 'GST' : 'NON-GST',
      data: {
        'vno': code,
        'partyName': name,
        'atype': atypeDescription,
        'city': city.isNotEmpty ? city : '-',
        'station': station.isNotEmpty ? station : '-',
        'broker': broker.isNotEmpty ? broker : 'SELF',
        'gstin': gstin.isNotEmpty ? gstin : '-',
        'mobile': mobile.isNotEmpty ? mobile : '-',
        'status': gstin.isNotEmpty ? 'GST' : 'NON-GST',
      },
      rawData: core.rawJson,
    );
  }
}
