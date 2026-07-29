import 'package:flutter/foundation.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_SERIES
================================================================================
Database Table: IMMBE2627.sq_SERIES (Master Series & Voucher Types Dictionary — 66 Columns)

PRIMARY KEY:
--------------------------------------------------------------------------------
- SERIESCODE (varchar, NOT NULL): Series Code Key (e.g. 'O13', 'P1', 'S1', 'R1', 'O5')

1. ACTIVELY USED MAPPED FIELDS (14 Mapped Fields):
--------------------------------------------------------------------------------
- SERIESCODE      : Series Code primary key (e.g. 'O13', 'P1')
- SERIES          : Official module/series description name
- BILLINGFORM     : Billing UI form renderer type ('CHALLAN', 'PURBILL', 'BILLSDIR')
- STOCKTYPE       : Fabric stock category ('GREY', 'FINISH', 'WORK', 'OTHER')
- BILLING         : Active billing type flag (boolean)
- DOC_TYPE        : Document classification type string
- STAGE_GROUP     : Production stage category group name
- STAGE_MAIN      : Primary production stage name
- STAGE_FINAL     : Is final production stage flag (boolean)
- CREATOR         : User creator string
- UPDATER         : User updater string
- CREATETIME      : Record creation timestamp
- UPDATETIME      : Record update timestamp
================================================================================
*/

/// [SqSeriesModel] — Canonical Core Data Model for `sq_SERIES` (Voucher Series Master).
@immutable
class SqSeriesModel {
  final String seriesCode;
  final String name;
  final String billingForm;
  final String stockType;
  final bool isBilling;
  final String docType;
  final String stageGroup;
  final String stageMain;
  final bool isFinalStage;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final Map<String, dynamic> rawJson;

  const SqSeriesModel({
    required this.seriesCode,
    required this.name,
    required this.billingForm,
    required this.stockType,
    required this.isBilling,
    required this.docType,
    required this.stageGroup,
    required this.stageMain,
    required this.isFinalStage,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  factory SqSeriesModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqSeriesModel(
      seriesCode: (json['SERIESCODE'] as String?)?.trim() ?? '',
      name: (json['SERIES'] as String?)?.trim() ?? '',
      billingForm: (json['BILLINGFORM'] as String?)?.trim() ?? '',
      stockType: (json['STOCKTYPE'] as String?)?.trim() ?? '',
      isBilling: json['BILLING'] == true || json['BILLING'] == 1,
      docType: (json['DOC_TYPE'] as String?)?.trim() ?? '',
      stageGroup: (json['STAGE_GROUP'] as String?)?.trim() ?? '',
      stageMain: (json['STAGE_MAIN'] as String?)?.trim() ?? '',
      isFinalStage: json['STAGE_FINAL'] == true || json['STAGE_FINAL'] == 1,
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseOptDate(json['CREATETIME']),
      lastEdited: parseOptDate(json['UPDATETIME']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'SERIESCODE': seriesCode,
    'SERIES': name,
    'BILLINGFORM': billingForm,
    'STOCKTYPE': stockType,
    'BILLING': isBilling,
    'DOC_TYPE': docType,
    'STAGE_GROUP': stageGroup,
    'STAGE_MAIN': stageMain,
    'STAGE_FINAL': isFinalStage,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  String get moduleGroup {
    if (seriesCode.startsWith('O')) return 'Purchase Orders / Work Challans';
    if (seriesCode.startsWith('P')) return 'Purchase Bills';
    if (seriesCode.startsWith('S')) return 'Sales Invoices';
    if (seriesCode.startsWith('R')) return 'Receipts & Payments';
    if (seriesCode.startsWith('C')) return 'Cutting Cards';
    return 'Other';
  }

  String get displayName => '$name ($seriesCode)';
}

/// Standardized UI Labels for `sq_SERIES`
abstract class SqSeriesLabels {
  static const String seriesCode = 'Series Code';
  static const String name = 'Module Name';
  static const String billingForm = 'Form Type';
  static const String stockType = 'Stock Type';
  static const String isBilling = 'Active Billing';
  static const String stageGroup = 'Stage Group';
  static const String stageMain = 'Stage Name';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SqSeriesModel`
extension SqSeriesTableMapper on SqSeriesModel {
  DynamicTableRowData toRowData() {
    return DynamicTableRowData(
      id: seriesCode,
      voucherNo: seriesCode,
      partyName: name,
      designPattern: moduleGroup,
      quantity: billingForm.isNotEmpty ? billingForm : 'N/A',
      amount: stockType.isNotEmpty ? stockType : 'N/A',
      amountValue: 0.0,
      status: isBilling ? 'ACTIVE' : 'INACTIVE',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SqSeriesLabels.seriesCode, key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SqSeriesLabels.name, key: 'partyName', flex: 4),
    DynamicTableColumnSpec(label: SqSeriesLabels.billingForm, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqSeriesLabels.stockType, key: 'amount', flex: 2),
    DynamicTableColumnSpec(label: SqSeriesLabels.isBilling, key: 'status', flex: 2),
  ];
}
