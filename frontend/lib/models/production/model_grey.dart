
/// [GreyProductionCard] — Represents an individual Job Card from Mill Dispatch.
class GreyProductionCard {
  final int cardNo;
  final int? vno;
  final DateTime receiveDate;
  final String weaverBillNo;
  final double meters;
  final int pieces;
  final String partyName;
  final String brokerCode;
  final String quality;
  final double rate;
  final String mill;
  final DateTime? dispatchDate;
  final int? despNo;
  final String processType;
  final int cno;
  final String type;

  GreyProductionCard({
    required this.cardNo,
    this.vno,
    required this.receiveDate,
    required this.weaverBillNo,
    required this.meters,
    required this.pieces,
    required this.partyName,
    required this.brokerCode,
    required this.quality,
    required this.rate,
    required this.mill,
    this.dispatchDate,
    this.despNo,
    required this.processType,
    required this.cno,
    required this.type,
  });

  factory GreyProductionCard.fromJson(Map<String, dynamic> json) {
    return GreyProductionCard(
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      vno: (json['VNO'] as num?)?.toInt(),
      receiveDate: DateTime.tryParse(json['RECEIVE_DATE'] ?? '') ?? DateTime.now(),
      weaverBillNo: json['WEAVER_BILL_NO'] ?? '',
      meters: (json['METERS'] as num?)?.toDouble() ?? 0.0,
      pieces: (json['PIECES'] as num?)?.toInt() ?? 0,
      partyName: json['PARTY_NAME'] ?? '',
      brokerCode: json['BROKER_CODE'] ?? '',
      quality: json['QUALITY'] ?? '',
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      mill: json['MILL'] ?? '',
      dispatchDate: DateTime.tryParse(json['DISPATCH_DATE'] ?? ''),
      despNo: (json['DESPNO'] as num?)?.toInt(),
      processType: json['PROCESSTYPE'] ?? '',
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      type: json['TYPE'] ?? 'P1',
    );
  }
}

/// [MillReceiveCard] — Represents a card received back from the mill.
class MillReceiveCard {
  final int recCardNo;
  final double wMts;
  final int wPcs;
  final double rate;
  final String greyQual;
  final int despNo;
  final int cardNo;
  final int cno;
  final int? vno;
  final String lot;
  final double rMts;
  final int rPcs;
  final double jobRate;
  final DateTime? billDate;

  MillReceiveCard({
    required this.recCardNo,
    required this.wMts,
    required this.wPcs,
    required this.rate,
    required this.greyQual,
    required this.despNo,
    required this.cardNo,
    required this.cno,
    this.vno,
    required this.lot,
    required this.rMts,
    required this.rPcs,
    required this.jobRate,
    this.billDate,
  });

  factory MillReceiveCard.fromJson(Map<String, dynamic> json) {
    return MillReceiveCard(
      recCardNo: (json['RECCARDNO'] as num?)?.toInt() ?? 0,
      wMts: (json['WMTS'] as num?)?.toDouble() ?? 0.0,
      wPcs: (json['WPCS'] as num?)?.toInt() ?? 0,
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      greyQual: json['GREYQUAL'] ?? '',
      despNo: (json['DESPNO'] as num?)?.toInt() ?? 0,
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      vno: (json['VNO'] as num?)?.toInt(),
      lot: json['lot'] ?? '',
      rMts: (json['RMTS'] as num?)?.toDouble() ?? 0.0,
      rPcs: (json['RPCS'] as num?)?.toInt() ?? 0,
      jobRate: (json['JOBRATE'] as num?)?.toDouble() ?? 0.0,
      billDate: DateTime.tryParse(json['BILL_DATE'] ?? ''),
    );
  }
}

class GreyPurchaseModel {
  final int vno;
  final String type;
  final String bill;
  final DateTime date;
  final String qual;
  final double rate;
  final String code; // Party
  final String? bcode; // Broker/Ledger
  final DateTime? rrDate;
  final double totMts;
  final int totPcs;
  final double vatAmt;
  final double billAmt;
  final double finalAmt;
  final double grossAmt;

  GreyPurchaseModel({
    required this.vno,
    required this.type,
    required this.bill,
    required this.date,
    required this.qual,
    required this.rate,
    required this.code,
    this.bcode,
    this.rrDate,
    required this.totMts,
    required this.totPcs,
    required this.vatAmt,
    required this.billAmt,
    required this.finalAmt,
    required this.grossAmt,
  });

  factory GreyPurchaseModel.fromJson(Map<String, dynamic> json) {
    return GreyPurchaseModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: json['TYPE'] ?? 'P1',
      bill: json['BILL'] ?? '',
      date: json['DATE'] != null ? DateTime.parse(json['DATE']) : DateTime.now(),
      qual: json['QUAL'] ?? '',
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      code: json['code'] ?? '',
      bcode: json['BCODE'] ?? '',
      rrDate: json['RRDATE'] != null ? DateTime.parse(json['RRDATE']) : null,
      totMts: (json['TOTMTS'] as num?)?.toDouble() ?? 0.0,
      totPcs: (json['TOTPCS'] as num?)?.toInt() ?? 0,
      vatAmt: (json['VATAMT'] as num?)?.toDouble() ?? 0.0,
      billAmt: (json['BILLAMT'] as num?)?.toDouble() ?? 0.0,
      finalAmt: (json['finalamt'] as num?)?.toDouble() ?? 0.0,
      grossAmt: (json['grossamt'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// [MillInwardModel] — Represents a job work inward bill (J1) from sq_BILLS.
/// Note: sq_BILLS (J1) lacks a direct 'rate' column; rates are in sq_PINVTRN.
class MillInwardModel {
  final int vno;
  final String bill;
  final DateTime date;
  final String qual;
  final double totMts;
  final int totPcs;
  final double vatAmt;
  final double billAmt;
  final double finalAmt;
  final double grossAmt;
  final double lessAdd1Amt;
  final double lessAdd1Rate;
  final String code;

  MillInwardModel({
    required this.vno,
    required this.bill,
    required this.date,
    required this.qual,
    required this.totMts,
    required this.totPcs,
    required this.vatAmt,
    required this.billAmt,
    required this.finalAmt,
    required this.grossAmt,
    required this.lessAdd1Amt,
    required this.lessAdd1Rate,
    required this.code,
  });

  factory MillInwardModel.fromJson(Map<String, dynamic> json) {
    return MillInwardModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      bill: json['BILL'] ?? '',
      date: json['DATE'] != null ? DateTime.parse(json['DATE']) : DateTime.now(),
      qual: json['QUAL'] ?? '',
      totMts: (json['TOTMTS'] as num?)?.toDouble() ?? 0.0,
      totPcs: (json['TOTPCS'] as num?)?.toInt() ?? 0,
      vatAmt: (json['VATAMT'] as num?)?.toDouble() ?? 0.0,
      billAmt: (json['BILLAMT'] as num?)?.toDouble() ?? 0.0,
      finalAmt: (json['finalamt'] as num?)?.toDouble() ?? 0.0,
      grossAmt: (json['grossamt'] as num?)?.toDouble() ?? 0.0,
      lessAdd1Amt: (json['LESSADD1AMT'] as num?)?.toDouble() ?? 0.0,
      lessAdd1Rate: (json['LESSADD1RATE'] as num?)?.toDouble() ?? 0.0,
      code: json['code'] ?? '',
    );
  }
}

/// [TakaModel] - The individual Taka (roll) detail from sq_PINVTRN.
class TakaModel {
  final int vno;
  final String type;
  final int srNo;
  final String qual;
  final String lotNo;
  final double mts;
  final double rate;
  final double amt;
  final String? shade;

  TakaModel({
    required this.vno,
    required this.type,
    required this.srNo,
    required this.qual,
    required this.lotNo,
    required this.mts,
    required this.rate,
    required this.amt,
    this.shade,
  });

  factory TakaModel.fromJson(Map<String, dynamic> json) {
    final double rateVal = (json['RATE'] as num?)?.toDouble() ?? 0.0;
    final double mtsVal = (json['PMTS'] as num?)?.toDouble() ??
        (json['WMTS'] as num?)?.toDouble() ??
        (json['RMTS'] as num?)?.toDouble() ??
        (json['MTS'] as num?)?.toDouble() ??
        0.0;
    final double amtVal = (json['AMT'] as num?)?.toDouble() ?? (mtsVal * rateVal);

    return TakaModel(
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: json['TYPE'] ?? '',
      srNo: (json['CARDNO'] as num?)?.toInt() ?? (json['SRNO'] as num?)?.toInt() ?? 0,
      qual: json['QUAL'] ?? '',
      lotNo: json['LOT'] ?? json['LOTNO'] ?? '',
      mts: mtsVal,
      rate: rateVal,
      amt: amtVal,
      shade: json['SHADE'] ?? json['DRMK'] ?? json['WRMK'],
    );
  }
}

/// [GreyDealModel] — Represents a Grey Deal / Purchase Order from sb_vw_pur_ord_summary.
class GreyDealModel {
  final int orderNo;
  final DateTime date;
  final String gcode; // Weaver
  final String? bcode; // Broker
  final String qual; // Quality
  final String unit; // 'PCS' or 'MTS'
  final int? pcs;
  final double? mts;
  final int? lots;
  final double rate;
  final double disc; // Dhara
  final int graceDays;
  final String? rmk;
  final int rcvPcs;
  final double rcvMts;
  final double pendingBal;
  final String closed;
  final String? weaverGroupName;

  GreyDealModel({
    required this.orderNo,
    required this.date,
    required this.gcode,
    this.bcode,
    required this.qual,
    required this.unit,
    this.pcs,
    this.mts,
    this.lots,
    required this.rate,
    required this.disc,
    required this.graceDays,
    this.rmk,
    required this.rcvPcs,
    required this.rcvMts,
    required this.pendingBal,
    required this.closed,
    this.weaverGroupName,
  });

  factory GreyDealModel.fromJson(Map<String, dynamic> json) {
    return GreyDealModel(
      orderNo: (json['ORDERNO'] as num?)?.toInt() ?? 0,
      date: json['DATE'] != null ? DateTime.parse(json['DATE']) : DateTime.now(),
      gcode: json['gcode'] ?? '',
      bcode: json['BCODE'],
      qual: json['QUAL'] ?? '',
      unit: json['UNIT'] ?? 'PCS',
      pcs: (json['PCS'] as num?)?.toInt(),
      mts: (json['MTS'] as num?)?.toDouble(),
      lots: (json['LOTS'] as num?)?.toInt(),
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      disc: (json['DISC'] as num?)?.toDouble() ?? 0.0,
      graceDays: (json['GRACEDAYS'] as num?)?.toInt() ?? 0,
      rmk: json['RMK'],
      rcvPcs: (json['RCV_PCS'] as num?)?.toInt() ?? 0,
      rcvMts: (json['RCV_MTS'] as num?)?.toDouble() ?? 0.0,
      pendingBal: (json['PENDING_BAL'] as num?)?.toDouble() ?? 0.0,
      closed: json['CLOSED'] ?? 'N',
      weaverGroupName: json['weaver_group_name'],
    );
  }
}

