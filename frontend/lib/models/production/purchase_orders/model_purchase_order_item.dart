import 'package:flutter/foundation.dart';
import 'purchase_order_category.dart';

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

/// [PurchaseOrderItemModel] - Line item detail record from `sq_BILLDET` for Purchase Orders.
@immutable
class PurchaseOrderItemModel {
  final int cno;
  final int vno;
  final String type;
  final POLineItemSourceTable sourceTable;
  final int srno; // Line Item Serial Number (SRNO)
  final String qual; // Item / Fabric Quality (qual)
  final int pcs; // Pieces (PCS)
  final double mts; // Meters (MTS)
  final double cut; // Cut length (CUT)
  final double rate; // Unit Rate (RATE)
  final double amt; // Total Amount (AMT)
  final String? unit; // Unit e.g. 'MTS', 'PCS', 'KG' (UNIT)
  final String? pack; // Packaging info (PACK)
  final String? details; // Description / Remarks (DETAILS)
  final String? closed; // Pendency status (CLOSED)

  const PurchaseOrderItemModel({
    required this.cno,
    required this.vno,
    required this.type,
    required this.sourceTable,
    required this.srno,
    required this.qual,
    required this.pcs,
    required this.mts,
    required this.cut,
    required this.rate,
    required this.amt,
    this.unit,
    this.pack,
    this.details,
    this.closed,
  });

  factory PurchaseOrderItemModel.fromJson(
    Map<String, dynamic> json, [
    POLineItemSourceTable sourceTable = POLineItemSourceTable.billdet,
  ]) {
    return PurchaseOrderItemModel(
      cno: _parseInt(json['CNO']),
      vno: _parseInt(json['VNO']),
      type: json['TYPE'] as String? ?? 'O13',
      sourceTable: sourceTable,
      srno: _parseInt(json['SRNO']),
      qual: json['qual'] as String? ?? json['BASEQUAL'] as String? ?? 'N/A',
      pcs: _parseInt(json['PCS']),
      mts: _parseDouble(json['MTS']),
      cut: _parseDouble(json['CUT']),
      rate: _parseDouble(json['RATE']),
      amt: _parseDouble(json['AMT']),
      unit: json['UNIT'] as String?,
      pack: json['PACK'] as String?,
      details: json['DETAILS'] as String?,
      closed: json['CLOSED'] as String?,
    );
  }

  /// Pendency evaluation as per Master Developer rules (null, '', or 'N' => pending)
  bool get isPending {
    if (closed == null) return true;
    final val = closed!.trim().toUpperCase();
    return val.isEmpty || val == 'N';
  }
}
