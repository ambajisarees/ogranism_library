/// ============================================================
/// PHASE 1 — Master Data Models
/// ============================================================
/// 
/// Type-safe model for the Account Ledger (sq_MASTER).
/// Maps all 79 columns into functional clusters.
/// ============================================================
library;

class PartyModel {
  // 1. IDENTITY & TYPE
  final String code;
  final String name;
  final String groupCode; // group_code from view
  final bool isGroupParent; // is_group_parent
  final int accountType; // ATYPE
  final String? adatiya; // ADATIYA
  final String? companyType; // companytype

  // 2. CONTACT INFO
  final String? mobile;
  final String? contactPerson; // CONTACT
  final String? address1;
  final String? address2;
  final String? fullAddress; // full_address
  final String? email;
  final String? flashRemark; // FLASH_RMK

  // 3. LOGICS & LOGISTICS
  final String city; // CITY1
  final String? station; 
  final String? transport;
  final double? distance;
  final String? pinNo; // PINNO

  // 4. FINANCIAL RULES (Legacy Settlement)
  final int creditDays; // crdays
  final double qualityDiscount; // qd
  final double brokerage; // bc
  final double dhara;
  final double tdsRate;

  // 5. COMPLIANCE
  final String? gstin;
  final String? pnrNo; // PNRNO

  PartyModel({
    required this.code,
    required this.name,
    required this.groupCode,
    required this.isGroupParent,
    required this.accountType,
    this.adatiya,
    this.companyType,
    this.mobile,
    this.contactPerson,
    this.address1,
    this.address2,
    this.fullAddress,
    this.email,
    this.flashRemark,
    required this.city,
    this.station,
    this.transport,
    this.distance,
    this.pinNo,
    required this.creditDays,
    required this.qualityDiscount,
    required this.brokerage,
    required this.dhara,
    required this.tdsRate,
    this.gstin,
    this.pnrNo,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PartyModel(
      code: json['code'] ?? '',
      name: json['NAME'] ?? 'Unknown Party',
      groupCode: json['group_code'] ?? '',
      isGroupParent: json['is_group_parent'] == true,
      accountType: parseInt(json['ATYPE']),
      adatiya: json['ADATIYA'],
      companyType: json['companytype'],
      mobile: json['MOBILE'],
      contactPerson: json['CONTACT'],
      address1: json['ADDRESS1'],
      address2: json['ADDRESS2'],
      fullAddress: json['full_address'],
      email: json['EMAIL'],
      flashRemark: json['FLASH_RMK'],
      city: json['CITY1'] ?? 'SURAT',
      station: json['STATION'],
      transport: json['TRANSPORT'],
      distance: parseDouble(json['DISTANCE']),
      pinNo: json['PINNO'],
      creditDays: parseInt(json['crdays']),
      qualityDiscount: parseDouble(json['qd']),
      brokerage: parseDouble(json['bc']),
      dhara: parseDouble(json['dhara']),
      tdsRate: parseDouble(json['TDSRATE']),
      gstin: json['GSTIN'],
      pnrNo: json['PNRNO'],
    );
  }
}
