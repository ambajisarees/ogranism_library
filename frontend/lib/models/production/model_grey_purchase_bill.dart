import 'package:flutter/foundation.dart';

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

/// [GreyPurchaseBillItemModel] - Line item record for Purchase Bills.
/// Handles both Grey Purchase (`P1` via `sq_PINVTRN`) and Process Job Work Bills (`J1` via `sq_MILLREC`).
@immutable
class GreyPurchaseBillItemModel {
  final int cardNo;
  final int vno;
  final int cno;
  final String type;
  final String qual;
  final String mill;
  final String weaver;
  final String? brokerCode;
  final double rate;
  final double wmts;
  final int wpcs;
  final String? wchal;
  final DateTime? wchdat;
  final DateTime? ddate;
  final int? despno;
  final bool isClosed;
  final String? lot;
  final double? panna;

  const GreyPurchaseBillItemModel({
    required this.cardNo,
    required this.vno,
    required this.cno,
    required this.type,
    required this.qual,
    required this.mill,
    required this.weaver,
    this.brokerCode,
    required this.rate,
    required this.wmts,
    required this.wpcs,
    this.wchal,
    this.wchdat,
    this.ddate,
    this.despno,
    required this.isClosed,
    this.lot,
    this.panna,
  });

  factory GreyPurchaseBillItemModel.fromJson(Map<String, dynamic> json) {
    final closedStr = (json['CLOSED'] as String?)?.toUpperCase() ?? '';
    final rateVal = _parseDouble(json['JOBRATE']) > 0
        ? _parseDouble(json['JOBRATE'])
        : (_parseDouble(json['RATE']) > 0
            ? _parseDouble(json['RATE'])
            : _parseDouble(json['PURRATE']));

    final qualVal = json['GREYQUAL'] as String? ?? (json['QUAL'] as String? ?? 'N/A');
    final millVal = json['MILL_CODE'] as String? ?? (json['MILL'] as String? ?? 'N/A');
    final weaverVal = json['WEAVER'] as String? ?? (json['MILL_CODE'] as String? ?? 'N/A');
    final wmtsVal = _parseDouble(json['RMTS']) > 0 ? _parseDouble(json['RMTS']) : _parseDouble(json['WMTS']);
    final wpcsVal = _parseInt(json['RPCS']) > 0 ? _parseInt(json['RPCS']) : _parseInt(json['WPCS']);
    final wchalVal = json['WCHAL'] as String? ?? json['chalno'] as String?;
    final wchdatVal = _parseDateTime(json['WCHDAT']) ?? _parseDateTime(json['chaldate']);
    final ddateVal = _parseDateTime(json['DDATE']) ?? _parseDateTime(json['CUTDATE']);

    return GreyPurchaseBillItemModel(
      cardNo: _parseInt(json['CARDNO']),
      vno: _parseInt(json['VNO']),
      cno: _parseInt(json['CNO']),
      type: json['TYPE'] as String? ?? 'P1',
      qual: qualVal,
      mill: millVal,
      weaver: weaverVal,
      brokerCode: json['BROKER_CODE'] as String?,
      rate: rateVal,
      wmts: wmtsVal,
      wpcs: wpcsVal,
      wchal: wchalVal,
      wchdat: wchdatVal,
      ddate: ddateVal,
      despno: json['DESPNO'] != null ? _parseInt(json['DESPNO']) : null,
      isClosed: closedStr == 'Y',
      lot: json['lot'] as String? ?? json['LOT'] as String?,
      panna: json['PANNA'] != null ? _parseDouble(json['PANNA']) : null,
    );
  }
}

/// [GreyPurchaseBillModel] - Header record from `sq_BILLS` for Grey (`P1`) & Process (`J1`) Bills.
@immutable
class GreyPurchaseBillModel {
  final int cno;
  final int vno; // Internal Bill Number
  final String type; // 'P1' (Grey) or 'J1' (Process)
  final String weaverBillNo; // Weaver / Mill Bill Number (BILL)
  final DateTime billDate; // Bill Date (DATE)
  final String partyCode; // Supplier / Weaver (P1) or Mill (J1) (code)
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
  final List<GreyPurchaseBillItemModel> items; // Joined line items (sq_PINVTRN for P1, sq_MILLREC for J1)

  const GreyPurchaseBillModel({
    required this.cno,
    required this.vno,
    required this.type,
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

  factory GreyPurchaseBillModel.fromJson(
    Map<String, dynamic> json, {
    List<GreyPurchaseBillItemModel> items = const [],
  }) {
    final parsedDate = _parseDateTime(json['DATE']) ?? DateTime.now();
    final parsedCreateTime = _parseDateTime(json['CREATETIME']);
    final billStr = json['BILL'] as String?;
    final vnoVal = _parseInt(json['VNO']);
    final typeVal = json['TYPE'] as String? ?? 'P1';

    final prefix = typeVal == 'J1' ? 'J1' : 'P1';
    final formattedWeaverBillNo = billStr != null && billStr.isNotEmpty
        ? billStr
        : '$prefix-${vnoVal.toString().padLeft(4, '0')}';

    return GreyPurchaseBillModel(
      cno: _parseInt(json['CNO']),
      vno: vnoVal,
      type: typeVal,
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

  bool get isGrey => type == 'P1';
  bool get isProcess => type == 'J1';

  /// Display Internal VNO (from sq_BILLS.VNO)
  String get displayInternalVno => '#$vno';

  /// Display Bill Number (from sq_BILLS.BILL)
  String get displayBillNo => weaverBillNo;

  /// Alias for displayBillNo
  String get displayWeaverBillNo => weaverBillNo;

  /// Display Party / Mill Name (from sq_BILLS.code)
  String get partyName => partyCode.isNotEmpty && partyCode != 'N/A' ? partyCode : 'N/A';

  /// Alias for partyName
  String get weaverName => partyName;

  /// Primary Mill Name from header or line items
  String get primaryMill {
    if (partyCode.isNotEmpty && partyCode != 'N/A') return partyCode;
    if (items.isNotEmpty && items.first.mill.isNotEmpty) return items.first.mill;
    return 'N/A';
  }

  /// Settlement status (from sq_BILLS.paid)
  bool get isPaid => paidStatus.toUpperCase() == 'Y';

  /// Base Quality Name (from sq_BILLS.QUAL or line items)
  String get primaryQuality {
    if (qual.isNotEmpty && qual != 'N/A') return qual;
    if (items.isNotEmpty && items.first.qual.isNotEmpty) return items.first.qual;
    return 'Grey Fabric';
  }

  /// Dynamic average rate per meter calculation
  double get calculatedAvgRate {
    if (avgRate > 0) return avgRate;
    if (totMts > 0 && finalAmt > 0) return finalAmt / totMts;
    return 0.0;
  }

  GreyPurchaseBillModel copyWith({List<GreyPurchaseBillItemModel>? items}) {
    return GreyPurchaseBillModel(
      cno: cno,
      vno: vno,
      type: type,
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
