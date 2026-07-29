import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_BILLS
================================================================================
Database Table: IMMBE2627.sq_BILLS (Airbyte Mirrored Read-Only Header Table — 25,820 rows)
Total Supabase Postgres Columns: 134 columns
Primary Composite Keys: CNO (bigint), VNO (bigint), TYPE (character varying)
Join Contract: BILLS.CNO = DETAIL.CNO AND BILLS.VNO = DETAIL.VNO AND BILLS.TYPE = DETAIL.TYPE

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (40 Mapped Fields):
--------------------------------------------------------------------------------
- CNO              : Company master ID (always 4)
- VNO              : Invoice voucher sequence number
- TYPE             : Voucher type category code
- BILL             : Party invoice number string
- DATE             : Invoice voucher issuance date
- code             : Primary party ledger name
- BCODE            : Broker or agent name
- cCODE            : Customer account ledger code
- haste            : Delivery agent / haste name
- RMK              : Voucher header remarks text
- QUAL             : Fabric quality header description
- RATE             : Grey purchase / sales rate
- BILLAMT          : Net invoice bill amount
- grossamt         : Subtotal amount before taxes
- finalamt         : Final bill amount post-tax
- TOTMTS           : Total bill fabric meters
- TOTPCS           : Total bill fabric pieces
- SENTMTS          : Total grey meters dispatched
- TRANSPORT        : Transporter logistics company name
- EWB_NO           : GST E-Way bill number
- RRNO             : Lorry receipt tracking number
- RRDATE           : Lorry receipt booking date
- paid             : Payment status flag (Y/N)
- TDSAMT           : Tax deducted at source
- TDSRATE          : TDS percentage rate applied
- TDS_CODE         : Tax deduction ledger code
- VATAMT           : GST / VAT tax amount
- VATRATE          : GST / VAT tax percentage
- PAYDAYS          : Credit period in days
- PAYDATE          : Financial payment due date
- REC_AMT          : Amount received / cleared
- BILLS_HSN_CODE   : Goods HSN tax code
- DISCOUNT         : Header discount amount deducted
- FREIGHT          : Freight transport charges added
- COMMPER          : Brokerage commission percentage rate
- COMMAMT          : Total brokerage commission amount
- CREATOR          : User ID who entered
- UPDATER          : User ID last edited
- CREATETIME       : Record creation timestamp
- UPDATETIME       : Record update timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- COMMAMT          : 0 non-null / 25,820 NULLs (100% NULL)
- DISPUTE          : 0 non-null / 25,820 NULLs (100% NULL)
- TDSDATE          : 0 non-null / 25,820 NULLs (100% NULL)
- commvno          : 0 non-null / 25,820 NULLs (100% NULL)
- GODOWN_NAME      : 0 non-null / 25,820 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (94 Fields Omitted):
--------------------------------------------------------------------------------
- PART             : Redundant party code (use code)
- ACODE            : Legacy account ledger code
- BILL_NO          : Duplicate invoice number string
- DISCPER          : Duplicate discount percentage rate
- ENTRYDATE        : Legacy data entry timestamp
- LOCK             : Record edit locking flag
- _airbyte_*       : Airbyte internal metadata fields
================================================================================
*/

/// [SqBillsModel] — Refined Canonical Model for `sq_BILLS` (Accounts & Invoicing Header).
@immutable
class SqBillsModel {
  final int cno;
  final int vno;
  final String type;
  final String billNo;
  final DateTime? date;
  final String partyName; // code
  final String brokerName; // BCODE
  final String customerCode; // cCODE
  final String haste; // haste
  final String remarks; // RMK
  final String quality; // QUAL
  final double rate; // RATE
  final double billAmount; // BILLAMT
  final double grossAmount; // grossamt
  final double finalAmount; // finalamt
  final double totalMeters; // TOTMTS
  final int totalPieces; // TOTPCS
  final double sentMeters; // SENTMTS
  final String transport; // TRANSPORT
  final String ewayBillNo; // EWB_NO
  final String lrNo; // RRNO
  final DateTime? lrDate; // RRDATE
  final String paymentStatus; // paid
  final double tdsAmount; // TDSAMT
  final double tdsRate; // TDSRATE
  final String tdsCode; // TDS_CODE
  final double vatAmount; // VATAMT
  final double vatRate; // VATRATE
  final int creditDays; // PAYDAYS
  final DateTime? dueDate; // PAYDATE
  final double recAmount; // REC_AMT
  final String hsnCode; // BILLS_HSN_CODE
  final double discount; // DISCOUNT
  final double freight; // FREIGHT
  final double commRate; // COMMPER
  final double commAmount; // COMMAMT
  final String author; // CREATOR
  final String updater; // UPDATER
  final DateTime? createdOn; // CREATETIME
  final DateTime? lastEdited; // UPDATETIME
  final Map<String, dynamic> rawJson;

  const SqBillsModel({
    required this.cno,
    required this.vno,
    required this.type,
    required this.billNo,
    this.date,
    required this.partyName,
    required this.brokerName,
    required this.customerCode,
    required this.haste,
    required this.remarks,
    required this.quality,
    required this.rate,
    required this.billAmount,
    required this.grossAmount,
    required this.finalAmount,
    required this.totalMeters,
    required this.totalPieces,
    required this.sentMeters,
    required this.transport,
    required this.ewayBillNo,
    required this.lrNo,
    this.lrDate,
    required this.paymentStatus,
    required this.tdsAmount,
    required this.tdsRate,
    required this.tdsCode,
    required this.vatAmount,
    required this.vatRate,
    required this.creditDays,
    this.dueDate,
    required this.recAmount,
    required this.hsnCode,
    required this.discount,
    required this.freight,
    required this.commRate,
    required this.commAmount,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  /// Defensive `fromJson` parser matching Postgres 17 types safely.
  factory SqBillsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqBillsModel(
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: (json['TYPE'] as String?)?.trim() ?? '',
      billNo: (json['BILL'] as String?)?.trim() ?? '',
      date: parseDate(json['DATE']),
      partyName: (json['code'] as String?)?.trim() ?? (json['PART'] as String?)?.trim() ?? '',
      brokerName: (json['BCODE'] as String?)?.trim() ?? '',
      customerCode: (json['cCODE'] as String?)?.trim() ?? '',
      haste: (json['haste'] as String?)?.trim() ?? '',
      remarks: (json['RMK'] as String?)?.trim() ?? '',
      quality: (json['QUAL'] as String?)?.trim() ?? '',
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      billAmount: (json['BILLAMT'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (json['grossamt'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalamt'] as num?)?.toDouble() ?? 0.0,
      totalMeters: (json['TOTMTS'] as num?)?.toDouble() ?? 0.0,
      totalPieces: (json['TOTPCS'] as num?)?.toInt() ?? 0,
      sentMeters: (json['SENTMTS'] as num?)?.toDouble() ?? 0.0,
      transport: (json['TRANSPORT'] as String?)?.trim() ?? '',
      ewayBillNo: (json['EWB_NO'] as String?)?.trim() ?? '',
      lrNo: (json['RRNO'] as String?)?.trim() ?? '',
      lrDate: parseDate(json['RRDATE']),
      paymentStatus: (json['paid'] as String?)?.trim() ?? 'N',
      tdsAmount: (json['TDSAMT'] as num?)?.toDouble() ?? 0.0,
      tdsRate: (json['TDSRATE'] as num?)?.toDouble() ?? 0.0,
      tdsCode: (json['TDS_CODE'] as String?)?.trim() ?? '',
      vatAmount: (json['VATAMT'] as num?)?.toDouble() ?? 0.0,
      vatRate: (json['VATRATE'] as num?)?.toDouble() ?? 0.0,
      creditDays: (json['PAYDAYS'] as num?)?.toInt() ?? 0,
      dueDate: parseDate(json['PAYDATE']),
      recAmount: (json['REC_AMT'] as num?)?.toDouble() ?? 0.0,
      hsnCode: (json['BILLS_HSN_CODE'] as String?)?.trim() ?? '',
      discount: (json['DISCOUNT'] as num?)?.toDouble() ?? (json['discamt'] as num?)?.toDouble() ?? 0.0,
      freight: (json['FREIGHT'] as num?)?.toDouble() ?? 0.0,
      commRate: (json['COMMPER'] as num?)?.toDouble() ?? 0.0,
      commAmount: (json['COMMAMT'] as num?)?.toDouble() ?? 0.0,
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'CNO': cno,
    'VNO': vno,
    'TYPE': type,
    'BILL': billNo,
    'DATE': date?.toIso8601String(),
    'code': partyName,
    'BCODE': brokerName,
    'cCODE': customerCode,
    'haste': haste,
    'RMK': remarks,
    'QUAL': quality,
    'RATE': rate,
    'BILLAMT': billAmount,
    'grossamt': grossAmount,
    'finalamt': finalAmount,
    'TOTMTS': totalMeters,
    'TOTPCS': totalPieces,
    'SENTMTS': sentMeters,
    'TRANSPORT': transport,
    'EWB_NO': ewayBillNo,
    'RRNO': lrNo,
    'RRDATE': lrDate?.toIso8601String(),
    'paid': paymentStatus,
    'TDSAMT': tdsAmount,
    'TDSRATE': tdsRate,
    'TDS_CODE': tdsCode,
    'VATAMT': vatAmount,
    'VATRATE': vatRate,
    'PAYDAYS': creditDays,
    'PAYDATE': dueDate?.toIso8601String(),
    'REC_AMT': recAmount,
    'BILLS_HSN_CODE': hsnCode,
    'DISCOUNT': discount,
    'FREIGHT': freight,
    'COMMPER': commRate,
    'COMMAMT': commAmount,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  bool get isGreyPurchase => type.toUpperCase() == 'P1';
  bool get isMillJobWork => type.toUpperCase() == 'J1';
  bool get isSalesInvoice => type.toUpperCase() == 'S1';
  bool get isCurrentFY => vno > 0 && vno < 100000;
  bool get isCarriedForward => vno >= 100000;
  double get effectiveRatePerMtr => totalMeters > 0 ? billAmount / totalMeters : rate;
}

/// Refined Standardized UI Field Labels for `sq_BILLS`
abstract class SqBillsLabels {
  static const String party = 'Party';
  static const String broker = 'Broker';
  static const String cno = 'CNO';
  static const String vocNo = 'VOC-No';
  static const String type = 'TYPE';
  static const String invNo = 'INV-No';
  static const String date = 'Date';
  static const String haste = 'Haste';
  static const String remarks = 'Remarks';
  static const String netAmt = 'Net Amt';
  static const String totMtrs = 'Tot Mtrs';
  static const String totalPcs = 'Total Pcs';
  static const String fabric = 'Fabric';
  static const String greyRate = 'Grey Rate';
  static const String grossAmt = 'Gross Amt';
  static const String finalAmt = 'Final Amt';
  static const String sentMtrs = 'Sent Mtrs';
  static const String transport = 'Transport';
  static const String ewbNo = 'EWB-No';
  static const String lrNo = 'LR-No';
  static const String lrDate = 'LR-Date';
  static const String pStat = 'P-Stat';
  static const String tdsAmt = 'TDS Amt';
  static const String vatAmt = 'VAT Amt';
  static const String vatRate = 'VAT %';
  static const String credit = 'Credit';
  static const String dueDate = 'Due Date';
  static const String recAmt = 'Rec Amt';
  static const String hsnNo = 'HSN-No';
  static const String tdsRate = 'TDS %';
  static const String tdsId = 'TDS-ID';
  static const String disc = 'Disc';
  static const String freight = 'Freight';
  static const String commRate = 'Comm %';
  static const String commAmt = 'Comm Amt';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SqBillsModel`
extension SqBillsTableMapper on SqBillsModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    final dateStr = date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'N/A';
    final targetAmt = finalAmount > 0 ? finalAmount : billAmount;

    return DynamicTableRowData(
      id: vno.toString(),
      voucherNo: 'PO #$vno',
      partyName: partyName.isNotEmpty ? partyName : 'Unknown Party',
      designPattern: quality.isNotEmpty ? quality : 'N/A',
      quantity: '${totalMeters.toInt()} Mtr',
      amount: fmt.format(targetAmt),
      amountValue: targetAmt,
      status: paymentStatus == 'Y' ? 'Paid' : 'Pending',
      rawData: {
        ...toJson(),
        'formattedDate': dateStr,
      },
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: 'Order #', key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SqBillsLabels.party, key: 'partyName', flex: 4),
    DynamicTableColumnSpec(label: SqBillsLabels.fabric, key: 'designPattern', flex: 3),
    DynamicTableColumnSpec(label: SqBillsLabels.totMtrs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqBillsLabels.netAmt, key: 'amount', flex: 3),
    DynamicTableColumnSpec(label: SqBillsLabels.pStat, key: 'status', flex: 2),
  ];
}
