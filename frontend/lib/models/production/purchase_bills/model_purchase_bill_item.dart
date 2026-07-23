import 'package:flutter/foundation.dart';
import 'purchase_bill_category.dart';

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

/// [PurchaseBillItemModel] - Unified line item model supporting `sq_PINVTRN`, `sq_MILLREC`, & `sq_BILLDET`.
@immutable
class PurchaseBillItemModel {
  final int id; // CARDNO or SRNO
  final int vno;
  final int cno;
  final String type;
  final String qual;
  final String partyName; // Weaver/Mill/Supplier
  final double rate;
  final double meters;
  final int pieces;
  final double amount;
  final String? challanNo;
  final DateTime? challanDate;
  final DateTime? dispatchDate;
  final int? dispatchNo;
  final bool isClosed;
  final String? lot;
  final String? details;
  final String? hsnCode;
  final LineItemSourceTable sourceTable;

  const PurchaseBillItemModel({
    required this.id,
    required this.vno,
    required this.cno,
    required this.type,
    required this.qual,
    required this.partyName,
    required this.rate,
    required this.meters,
    required this.pieces,
    required this.amount,
    this.challanNo,
    this.challanDate,
    this.dispatchDate,
    this.dispatchNo,
    required this.isClosed,
    this.lot,
    this.details,
    this.hsnCode,
    required this.sourceTable,
  });

  factory PurchaseBillItemModel.fromJson(Map<String, dynamic> json, LineItemSourceTable source) {
    final typeVal = json['TYPE'] as String? ?? '';
    final closedStr = (json['CLOSED'] as String?)?.toUpperCase() ?? '';
    final isClosedVal = closedStr == 'Y' || (json['CLOSED_UNCUT'] as String?)?.toUpperCase() == 'Y';

    if (source == LineItemSourceTable.pinvtrn) {
      // 1. Mapped from sq_PINVTRN (Grey Takhta rolls)
      final rateVal = _parseDouble(json['RATE']) > 0
          ? _parseDouble(json['RATE'])
          : _parseDouble(json['PURRATE']);
      final mts = _parseDouble(json['WMTS']);
      final pcs = _parseInt(json['WPCS']);
      final amt = _parseDouble(json['AMT']) > 0 ? _parseDouble(json['AMT']) : (mts * rateVal);

      return PurchaseBillItemModel(
        id: _parseInt(json['CARDNO']),
        vno: _parseInt(json['VNO']),
        cno: _parseInt(json['CNO']),
        type: typeVal,
        qual: json['QUAL'] as String? ?? 'N/A',
        partyName: json['WEAVER'] as String? ?? json['MILL'] as String? ?? 'N/A',
        rate: rateVal,
        meters: mts,
        pieces: pcs,
        amount: amt,
        challanNo: json['WCHAL'] as String?,
        challanDate: _parseDateTime(json['WCHDAT']),
        dispatchDate: _parseDateTime(json['DDATE']),
        dispatchNo: json['DESPNO'] != null ? _parseInt(json['DESPNO']) : null,
        isClosed: isClosedVal,
        lot: json['LOT'] as String?,
        sourceTable: LineItemSourceTable.pinvtrn,
      );
    } else if (source == LineItemSourceTable.millrec) {
      // 2. Mapped from sq_MILLREC (Mill receipt records)
      final rateVal = _parseDouble(json['JOBRATE']) > 0
          ? _parseDouble(json['JOBRATE'])
          : (_parseDouble(json['RATE']) > 0 ? _parseDouble(json['RATE']) : _parseDouble(json['PURRATE']));
      final mts = _parseDouble(json['RMTS']) > 0 ? _parseDouble(json['RMTS']) : _parseDouble(json['WMTS']);
      final pcs = _parseInt(json['RPCS']) > 0 ? _parseInt(json['RPCS']) : _parseInt(json['WPCS']);
      final amt = mts * rateVal;

      return PurchaseBillItemModel(
        id: _parseInt(json['CARDNO']),
        vno: _parseInt(json['VNO']),
        cno: _parseInt(json['CNO']),
        type: typeVal,
        qual: json['GREYQUAL'] as String? ?? json['QUAL'] as String? ?? 'N/A',
        partyName: json['MILL_CODE'] as String? ?? 'N/A',
        rate: rateVal,
        meters: mts,
        pieces: pcs,
        amount: amt,
        challanNo: json['chalno'] as String? ?? json['WCHAL'] as String?,
        challanDate: _parseDateTime(json['chaldate']) ?? _parseDateTime(json['WCHDAT']),
        dispatchDate: _parseDateTime(json['CUTDATE']) ?? _parseDateTime(json['DDATE']),
        dispatchNo: json['DESPNO'] != null ? _parseInt(json['DESPNO']) : null,
        isClosed: isClosedVal,
        lot: json['lot'] as String? ?? json['LOT'] as String?,
        sourceTable: LineItemSourceTable.millrec,
      );
    } else {
      // 3. Mapped from sq_BILLDET (Standard bill detail lines)
      final rateVal = _parseDouble(json['RATE']);
      final mts = _parseDouble(json['MTS']);
      final pcs = _parseInt(json['PCS']);
      final amtVal = _parseDouble(json['AMT']) > 0 ? _parseDouble(json['AMT']) : (mts * rateVal);
      final qualStr = json['qual'] as String? ?? json['BASEQUAL'] as String? ?? 'N/A';

      return PurchaseBillItemModel(
        id: _parseInt(json['SRNO']),
        vno: _parseInt(json['VNO']),
        cno: _parseInt(json['CNO']),
        type: typeVal,
        qual: qualStr,
        partyName: json['REFPTY'] as String? ?? 'N/A',
        rate: rateVal,
        meters: mts,
        pieces: pcs,
        amount: amtVal,
        challanNo: json['ORDBILL'] as String?,
        details: json['DETAILS'] as String?,
        hsnCode: json['HSN_CODE'] as String?,
        isClosed: isClosedVal,
        sourceTable: LineItemSourceTable.billdet,
      );
    }
  }
}
