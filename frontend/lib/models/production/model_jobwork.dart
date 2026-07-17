import 'package:meta/meta.dart';

/// [JobDispatchModel] — Represents a Stitching Dispatch (O5) voucher header from `sq_BILLS`.
@immutable
class JobDispatchModel {
  final int vno;
  final String type;
  final int cno;
  final DateTime date;
  final String tailorCode; // party code (BILLS.code)
  final String? tailorName; // Resolved name from sq_MASTER
  final double totMts;
  final int totPcs;
  final double finalAmt;
  final String? challanNo;
  final String? billNo;

  const JobDispatchModel({
    required this.vno,
    required this.type,
    required this.cno,
    required this.date,
    required this.tailorCode,
    this.tailorName,
    required this.totMts,
    required this.totPcs,
    required this.finalAmt,
    this.challanNo,
    this.billNo,
  });

  factory JobDispatchModel.fromJson(Map<String, dynamic> json) {
    return JobDispatchModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: json['TYPE'] ?? 'O5',
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      date: json['DATE'] != null ? DateTime.parse(json['DATE'].toString()) : DateTime.now(),
      tailorCode: json['code'] as String? ?? 'N/A',
      tailorName: json['tailor_name'] as String? ?? json['code'] as String?,
      totMts: (json['TOTMTS'] as num?)?.toDouble() ?? 0.0,
      totPcs: (json['TOTPCS'] as num?)?.toInt() ?? 0,
      finalAmt: (json['finalamt'] as num?)?.toDouble() ?? 0.0,
      challanNo: json['CHALLAN'] as String?,
      billNo: json['BILL'] as String?,
    );
  }
}

/// [JobReceiveModel] — Represents a Stitching Receive (O6) voucher header from `sq_BILLS`.
@immutable
class JobReceiveModel {
  final int vno;
  final String type;
  final int cno;
  final DateTime date;
  final String tailorCode;
  final String? tailorName;
  final double totMts;
  final int totPcs;
  final double finalAmt;
  final String? challanNo;
  final String? billNo;

  const JobReceiveModel({
    required this.vno,
    required this.type,
    required this.cno,
    required this.date,
    required this.tailorCode,
    this.tailorName,
    required this.totMts,
    required this.totPcs,
    required this.finalAmt,
    this.challanNo,
    this.billNo,
  });

  factory JobReceiveModel.fromJson(Map<String, dynamic> json) {
    return JobReceiveModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: json['TYPE'] ?? 'O6',
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      date: json['DATE'] != null ? DateTime.parse(json['DATE'].toString()) : DateTime.now(),
      tailorCode: json['code'] as String? ?? 'N/A',
      tailorName: json['tailor_name'] as String? ?? json['code'] as String?,
      totMts: (json['TOTMTS'] as num?)?.toDouble() ?? 0.0,
      totPcs: (json['TOTPCS'] as num?)?.toInt() ?? 0,
      finalAmt: (json['finalamt'] as num?)?.toDouble() ?? 0.0,
      challanNo: json['CHALLAN'] as String?,
      billNo: json['BILL'] as String?,
    );
  }
}

/// [JobWorkDetailLineModel] — Represents a specific detail item row in `sq_BILLDET` for O5 and O6.
@immutable
class JobWorkDetailLineModel {
  final int vno;
  final String type;
  final int cno;
  final int srNo;
  final String quality;
  final double pieces;
  final double meters;
  final double rate;
  final double amt;
  final bool isClosed;
  final int? cuttingCardNo; // orderno pointing to CUTCARDNO
  final String? ordType;    // ORDTYPE
  final int? stageVno;     // STAGE_VNO
  final String? stageType;  // STAGE_TYPE

  const JobWorkDetailLineModel({
    required this.vno,
    required this.type,
    required this.cno,
    required this.srNo,
    required this.quality,
    required this.pieces,
    required this.meters,
    required this.rate,
    required this.amt,
    required this.isClosed,
    this.cuttingCardNo,
    this.ordType,
    this.stageVno,
    this.stageType,
  });

  factory JobWorkDetailLineModel.fromJson(Map<String, dynamic> json) {
    return JobWorkDetailLineModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: json['TYPE'] ?? '',
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      srNo: (json['SRNO'] as num?)?.toInt() ?? 0,
      quality: json['qual'] as String? ?? 'N/A',
      pieces: (json['PCS'] as num?)?.toDouble() ?? 0.0,
      meters: (json['MTS'] as num?)?.toDouble() ?? 0.0,
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      amt: (json['AMT'] as num?)?.toDouble() ?? 0.0,
      isClosed: (json['CLOSED'] as String?)?.toUpperCase() == 'Y',
      cuttingCardNo: (json['orderno'] as num?)?.toInt(),
      ordType: json['ORDTYPE'] as String?,
      stageVno: (json['STAGE_VNO'] as num?)?.toInt(),
      stageType: json['STAGE_TYPE'] as String?,
    );
  }
}
