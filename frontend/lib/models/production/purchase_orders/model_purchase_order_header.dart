import 'package:flutter/foundation.dart';
import 'purchase_order_category.dart';
import 'model_purchase_order_item.dart';

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

/// [PurchaseOrderHeaderModel] - Header record from `sq_BILLS` for Purchase Orders (`O13`, `O14`, `O15`, `O16`).
@immutable
class PurchaseOrderHeaderModel {
  final int cno;
  final int vno; // Internal Order VNO
  final String type; // ERP Series Code (TYPE) e.g., 'O13', 'O14', 'O15', 'O16'
  final PurchaseOrderCategory category; // Category Enum
  final String orderNo; // Party/Order Number (BILL or ORDERNO)
  final DateTime orderDate; // Order Date (DATE)
  final String partyCode; // Supplier/Vendor Name (code)
  final String qual; // Fabric/Product Quality (QUAL)
  final String brokerCode; // Broker (BCODE)
  final int parcels; // Parcels (PARCELS)
  final int totPcs; // Total Pieces (TOTPCS)
  final double totMts; // Total Meters (TOTMTS)
  final double avgRate; // Header Rate (RATE)
  final double billAmt; // Total Order Amount (BILLAMT)
  final double grossAmt; // Gross Amount (grossamt)
  final double finalAmt; // Net Final Amount (finalamt)
  final String paidStatus; // Status indicator (paid)
  final String? remarks; // Remarks (RMK)
  final String creator; // Creator (CREATOR)
  final DateTime? createTime; // Create Time
  final List<PurchaseOrderItemModel> items; // Joined line items

  const PurchaseOrderHeaderModel({
    required this.cno,
    required this.vno,
    required this.type,
    required this.category,
    required this.orderNo,
    required this.orderDate,
    required this.partyCode,
    required this.qual,
    required this.brokerCode,
    required this.parcels,
    required this.totPcs,
    required this.totMts,
    required this.avgRate,
    required this.billAmt,
    required this.grossAmt,
    required this.finalAmt,
    required this.paidStatus,
    this.remarks,
    required this.creator,
    this.createTime,
    this.items = const [],
  });

  factory PurchaseOrderHeaderModel.fromJson(
    Map<String, dynamic> json, {
    List<PurchaseOrderItemModel> items = const [],
  }) {
    final parsedDate = _parseDateTime(json['DATE']) ?? DateTime.now();
    final parsedCreateTime = _parseDateTime(json['CREATETIME']);
    final billStr = json['BILL'] as String? ?? json['ORDERNO'] as String?;
    final vnoVal = _parseInt(json['VNO']);
    final typeVal = json['TYPE'] as String? ?? 'O13';

    final categoryVal = PurchaseOrderCategoryExtension.fromSeriesCode(typeVal);
    final prefix = categoryVal.seriesCode?.toUpperCase() ?? 'PO';
    final formattedOrderNo = billStr != null && billStr.isNotEmpty
        ? billStr
        : '$prefix-${vnoVal.toString().padLeft(4, '0')}';

    return PurchaseOrderHeaderModel(
      cno: _parseInt(json['CNO']),
      vno: vnoVal,
      type: typeVal,
      category: categoryVal,
      orderNo: formattedOrderNo,
      orderDate: parsedDate,
      partyCode: json['code'] as String? ?? 'N/A',
      qual: json['QUAL'] as String? ?? 'N/A',
      brokerCode: json['BCODE'] as String? ?? 'N/A',
      parcels: _parseInt(json['PARCELS']),
      totPcs: _parseInt(json['TOTPCS']),
      totMts: _parseDouble(json['TOTMTS']),
      avgRate: _parseDouble(json['RATE']),
      billAmt: _parseDouble(json['BILLAMT']),
      grossAmt: _parseDouble(json['grossamt']),
      finalAmt: _parseDouble(json['finalamt']),
      paidStatus: json['paid'] as String? ?? 'N',
      remarks: json['RMK'] as String?,
      creator: json['CREATOR'] as String? ?? '',
      createTime: parsedCreateTime,
      items: items,
    );
  }

  /// Display Internal VNO (from sq_BILLS.VNO)
  String get displayInternalVno => '#$vno';

  /// Display Order Number
  String get displayOrderNo => orderNo;

  /// Display Supplier/Vendor Name (from sq_BILLS.code)
  String get partyName => partyCode.isNotEmpty && partyCode != 'N/A' ? partyCode : 'N/A';

  /// Quality Name
  String get primaryQuality {
    if (qual.isNotEmpty && qual != 'N/A') return qual;
    if (items.isNotEmpty && items.first.qual.isNotEmpty) return items.first.qual;
    return 'N/A';
  }

  PurchaseOrderHeaderModel copyWith({List<PurchaseOrderItemModel>? items}) {
    return PurchaseOrderHeaderModel(
      cno: cno,
      vno: vno,
      type: type,
      category: category,
      orderNo: orderNo,
      orderDate: orderDate,
      partyCode: partyCode,
      qual: qual,
      brokerCode: brokerCode,
      parcels: parcels,
      totPcs: totPcs,
      totMts: totMts,
      avgRate: avgRate,
      billAmt: billAmt,
      grossAmt: grossAmt,
      finalAmt: finalAmt,
      paidStatus: paidStatus,
      remarks: remarks,
      creator: creator,
      createTime: createTime,
      items: items ?? this.items,
    );
  }
}
