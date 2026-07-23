import 'package:flutter/foundation.dart';
import 'purchase_bill_category.dart';
import 'model_purchase_bill_item.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

DateTime? _parseDateTime(dynamic val) {
  if (val == null) return null;
  return DateTime.tryParse(val.toString());
}

/// [PurchaseBillHeaderModel] - Header record from `sq_BILLS` for any of the 10 Purchase Bill categories.
@immutable
class PurchaseBillHeaderModel {
  final int cno;
  final int vno; // Internal Bill Number (VNO)
  final String type; // ERP Series Code (TYPE)
  final PurchaseBillCategory category; // Category Enum
  final String weaverBillNo; // Party/Weaver/Mill Bill Number (BILL)
  final DateTime billDate; // Bill Date (DATE)
  final String partyCode; // Supplier/Weaver/Mill Name (code)
  final String qual; // Base Fabric Quality (QUAL)
  final String brokerCode; // Broker (BCODE)
  final int parcels; // Parcels (PARCELS)
  final int totPcs; // Total Pieces (TOTPCS)
  final double totMts; // Total Meters (TOTMTS)
  final double avgRate; // Header Rate (RATE)
  final double billAmt; // Total Bill Amount (BILLAMT)
  final double grossAmt; // Gross Amount (grossamt)
  final double vatRate; // Tax Rate (VATRATE)
  final double vatAmt; // Tax Amount (VATAMT)
  final double freight; // Freight (FREIGHT)
  final double discount; // Discount (DISCOUNT)
  final double finalAmt; // Net Final Amount (finalamt)
  final String paidStatus; // Settlement status ('Y' / 'N') (paid)
  final String? hsnCode; // HSN Code (BILLS_HSN_CODE)
  final String? transport; // Transport (TRANSPORT)
  final String creator; // Creator (CREATOR)
  final DateTime? createTime; // Create Time
  final List<PurchaseBillItemModel> items; // Joined line items

  const PurchaseBillHeaderModel({
    required this.cno,
    required this.vno,
    required this.type,
    required this.category,
    required this.weaverBillNo,
    required this.billDate,
    required this.partyCode,
    required this.qual,
    required this.brokerCode,
    required this.parcels,
    required this.totPcs,
    required this.totMts,
    required this.avgRate,
    required this.billAmt,
    required this.grossAmt,
    required this.vatRate,
    required this.vatAmt,
    required this.freight,
    required this.discount,
    required this.finalAmt,
    required this.paidStatus,
    this.hsnCode,
    this.transport,
    required this.creator,
    this.createTime,
    this.items = const [],
  });

  factory PurchaseBillHeaderModel.fromJson(
    Map<String, dynamic> json, {
    List<PurchaseBillItemModel> items = const [],
  }) {
    final parsedDate = _parseDateTime(json['DATE']) ?? DateTime.now();
    final parsedCreateTime = _parseDateTime(json['CREATETIME']);
    final billStr = json['BILL'] as String?;
    final vnoVal = _parseInt(json['VNO']);
    final typeVal = json['TYPE'] as String? ?? 'P1';

    final categoryVal = PurchaseBillCategoryExtension.fromSeriesCode(typeVal);
    final prefix = categoryVal.seriesCode.toUpperCase();
    final formattedWeaverBillNo = billStr != null && billStr.isNotEmpty
        ? billStr
        : '$prefix-${vnoVal.toString().padLeft(4, '0')}';

    return PurchaseBillHeaderModel(
      cno: _parseInt(json['CNO']),
      vno: vnoVal,
      type: typeVal,
      category: categoryVal,
      weaverBillNo: formattedWeaverBillNo,
      billDate: parsedDate,
      partyCode: json['code'] as String? ?? 'N/A',
      qual: json['QUAL'] as String? ?? 'N/A',
      brokerCode: json['BCODE'] as String? ?? 'N/A',
      parcels: _parseInt(json['PARCELS']),
      totPcs: _parseInt(json['TOTPCS']),
      totMts: _parseDouble(json['TOTMTS']),
      avgRate: _parseDouble(json['RATE']),
      billAmt: _parseDouble(json['BILLAMT']),
      grossAmt: _parseDouble(json['grossamt']),
      vatRate: _parseDouble(json['VATRATE']),
      vatAmt: _parseDouble(json['VATAMT']) > 0
          ? _parseDouble(json['VATAMT'])
          : _parseDouble(json['ADD_VATAMT']),
      freight: _parseDouble(json['FREIGHT']),
      discount: _parseDouble(json['DISCOUNT']) > 0
          ? _parseDouble(json['DISCOUNT'])
          : _parseDouble(json['discamt']),
      finalAmt: _parseDouble(json['finalamt']),
      paidStatus: json['paid'] as String? ?? 'N',
      hsnCode: json['BILLS_HSN_CODE'] as String?,
      transport: json['TRANSPORT'] as String?,
      creator: json['CREATOR'] as String? ?? '',
      createTime: parsedCreateTime,
      items: items,
    );
  }

  /// Display Internal VNO (from sq_BILLS.VNO)
  String get displayInternalVno => '#$vno';

  /// Display Bill Number (from sq_BILLS.BILL)
  String get displayBillNo => weaverBillNo;

  /// Display Party / Mill / Supplier Name (from sq_BILLS.code)
  String get partyName => partyCode.isNotEmpty && partyCode != 'N/A' ? partyCode : 'N/A';

  /// Settlement status (from sq_BILLS.paid)
  bool get isPaid => paidStatus.toUpperCase() == 'Y';

  /// Base Quality Name (from sq_BILLS.QUAL or line items)
  String get primaryQuality {
    if (qual.isNotEmpty && qual != 'N/A') return qual;
    if (items.isNotEmpty && items.first.qual.isNotEmpty) return items.first.qual;
    return 'N/A';
  }

  /// Dynamic average rate per meter calculation
  double get calculatedAvgRate {
    if (avgRate > 0) return avgRate;
    if (totMts > 0 && finalAmt > 0) return finalAmt / totMts;
    return 0.0;
  }

  PurchaseBillHeaderModel copyWith({List<PurchaseBillItemModel>? items}) {
    return PurchaseBillHeaderModel(
      cno: cno,
      vno: vno,
      type: type,
      category: category,
      weaverBillNo: weaverBillNo,
      billDate: billDate,
      partyCode: partyCode,
      qual: qual,
      brokerCode: brokerCode,
      parcels: parcels,
      totPcs: totPcs,
      totMts: totMts,
      avgRate: avgRate,
      billAmt: billAmt,
      grossAmt: grossAmt,
      vatRate: vatRate,
      vatAmt: vatAmt,
      freight: freight,
      discount: discount,
      finalAmt: finalAmt,
      paidStatus: paidStatus,
      hsnCode: hsnCode,
      transport: transport,
      creator: creator,
      createTime: createTime,
      items: items ?? this.items,
    );
  }
}
