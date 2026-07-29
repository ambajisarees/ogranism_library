import 'package:flutter/foundation.dart';

/// [MillPendingBalanceModel] — Immutable model representing an individual unreceived pending Lot Card at a Mill.
@immutable
class MillPendingBalanceModel {
  final int cardNo;
  final int millId;
  final String millName;
  final String greyQuality;
  final double sentMtrs;
  final double receivedMtrs;
  final double pendingMtrs;
  final int pendingCardCount;
  final double avgGreyRate;
  final double totalPendingValue;
  final String lastCutDateStr;
  final bool isCarriedForward;

  const MillPendingBalanceModel({
    required this.cardNo,
    required this.millId,
    required this.millName,
    required this.greyQuality,
    required this.sentMtrs,
    required this.receivedMtrs,
    required this.pendingMtrs,
    required this.pendingCardCount,
    required this.avgGreyRate,
    required this.totalPendingValue,
    required this.lastCutDateStr,
    this.isCarriedForward = false,
  });

  factory MillPendingBalanceModel.fromJson(Map<String, dynamic> json) {
    final sent = (json['sent_mtrs'] as num?)?.toDouble() ?? (json['WMTS'] as num?)?.toDouble() ?? (json['MTR'] as num?)?.toDouble() ?? 0.0;
    final rec = (json['rec_mtrs'] as num?)?.toDouble() ?? (json['RECMTR'] as num?)?.toDouble() ?? 0.0;
    final pend = (json['pending_mtrs'] as num?)?.toDouble() ?? (sent - rec).clamp(0.0, double.infinity);
    final rate = (json['avg_rate'] as num?)?.toDouble() ?? (json['RATE'] as num?)?.toDouble() ?? (json['PURRATE'] as num?)?.toDouble() ?? 0.0;
    final card = (json['card_no'] as num?)?.toInt() ?? (json['CARDNO'] as num?)?.toInt() ?? 0;

    return MillPendingBalanceModel(
      cardNo: card,
      millId: (json['mill_id'] as num?)?.toInt() ?? (json['PARTY'] as num?)?.toInt() ?? 0,
      millName: json['mill_name']?.toString() ?? json['MILL']?.toString() ?? json['WEAVER']?.toString() ?? 'Unknown Mill',
      greyQuality: json['grey_quality']?.toString() ?? json['QUAL']?.toString() ?? json['ITEM']?.toString() ?? 'Grey Quality',
      sentMtrs: sent,
      receivedMtrs: rec,
      pendingMtrs: pend,
      pendingCardCount: (json['pending_card_count'] as num?)?.toInt() ?? 1,
      avgGreyRate: rate,
      totalPendingValue: pend * rate,
      lastCutDateStr: json['DDATE']?.toString().split('T').first ?? json['last_date']?.toString() ?? 'N/A',
      isCarriedForward: card >= 100000,
    );
  }

  Map<String, dynamic> toJson() => {
    'card_no': cardNo,
    'mill_id': millId,
    'mill_name': millName,
    'grey_quality': greyQuality,
    'sent_mtrs': sentMtrs,
    'rec_mtrs': receivedMtrs,
    'pending_mtrs': pendingMtrs,
    'pending_card_count': pendingCardCount,
    'avg_rate': avgGreyRate,
    'total_pending_value': totalPendingValue,
    'last_date': lastCutDateStr,
    'is_cf': isCarriedForward,
  };
}
