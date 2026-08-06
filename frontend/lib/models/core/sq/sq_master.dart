/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ MASTER MODEL (sq_master.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical 1-to-1 data model for table `IMMBE2627.sq_MASTER` (Party Ledger Master — 5,502 rows).
   - Airbyte-managed read-only mirror of MSSQL AMAZE Party Master table.
   - Stores account profiles for Customers (Sundry Debtors), Grey Suppliers, Dyeing Mills, Embroidery Units, Brokers, and Staff.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Primary Key: `code` (100% unique string identifier).
   - Identity: `NAME` (100% populated legal display name).
   - `ATYPE` Silos:
     - 1: SUNDRY DEBTORS (2,703 Customers)
     - 2: CREDITORS FOR GREY (772 Weavers/Grey Suppliers)
     - 12: CREDITORS FOR BROKERAGE (496 Commission Agents)
     - 119: CREDITORS FOR EMB. JOB CHARGE (244 Embroidery Units)
     - 14: CREDITORS FOR DYEING JOB CHARG (99 Processing Mills)
     - 106/113/17/others: Overheads, General Suppliers, Staff (1,073 items)
   - Geography & Logistics: `CITY1` (Billing city), `STATION` (Logistics transport hub), `ADATIYA` (Linked broker).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` is Airbyte-managed and Strictly Read-Only.
   - `MOBILE` is populated for ~70% of commercial parties for WhatsApp outreach.
   - `GSTIN` is populated for 61.9% of parties (B2B Tax Compliance).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should `ADATIYA = 'SELF'` be treated as direct dealing (no agent commission)?
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';

/// [SqMasterModel] — Refined Canonical 1-to-1 Data Model for `sq_MASTER` (Party Master).
@immutable
class SqMasterModel {
  final String code;
  final String name;
  final int atype;
  final String gcode;
  final String city1;
  final String station;
  final String adatiya;
  final String mobile;
  final String gstin;
  final String address1;
  final String address2;
  final String transport;
  final double distance;
  final String contact;
  final String state1;
  final String pinNo;
  final int crDays;
  final double tdsRate;
  final String flashRmk;
  final String email;
  final String msmeNo;
  final String companyType;
  final int custType;
  final String bankName;
  final String bankAcNo;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final DateTime? syncTime;
  final Map<String, dynamic> rawJson;

  const SqMasterModel({
    required this.code,
    required this.name,
    required this.atype,
    required this.gcode,
    required this.city1,
    required this.station,
    required this.adatiya,
    required this.mobile,
    required this.gstin,
    required this.address1,
    required this.address2,
    required this.transport,
    required this.distance,
    required this.contact,
    required this.state1,
    required this.pinNo,
    required this.crDays,
    required this.tdsRate,
    required this.flashRmk,
    required this.email,
    required this.msmeNo,
    required this.companyType,
    required this.custType,
    required this.bankName,
    required this.bankAcNo,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    this.syncTime,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory handling Postgres 17 types safely.
  factory SqMasterModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqMasterModel(
      code: (json['code'] as String?)?.trim() ?? '',
      name: (json['NAME'] as String?)?.trim() ?? (json['code'] as String?)?.trim() ?? 'N/A',
      atype: (json['ATYPE'] as num?)?.toInt() ?? 0,
      gcode: (json['GCODE'] as String?)?.trim() ?? '',
      city1: (json['CITY1'] as String?)?.trim() ?? '',
      station: (json['STATION'] as String?)?.trim() ?? (json['CITY1'] as String?)?.trim() ?? '',
      adatiya: (json['ADATIYA'] as String?)?.trim() ?? 'SELF',
      mobile: (json['MOBILE'] as String?)?.trim() ?? (json['PHONE1'] as String?)?.trim() ?? '',
      gstin: (json['GSTIN'] as String?)?.trim() ?? '',
      address1: (json['ADDRESS1'] as String?)?.trim() ?? '',
      address2: (json['ADDRESS2'] as String?)?.trim() ?? '',
      transport: (json['TRANSPORT'] as String?)?.trim() ?? '',
      distance: (json['DISTANCE'] as num?)?.toDouble() ?? 0.0,
      contact: (json['CONTACT'] as String?)?.trim() ?? '',
      state1: (json['STATE1'] as String?)?.trim() ?? '',
      pinNo: (json['PINNO'] as String?)?.trim() ?? '',
      crDays: (json['crdays'] as num?)?.toInt() ?? 0,
      tdsRate: (json['TDSRATE'] as num?)?.toDouble() ?? 0.0,
      flashRmk: (json['FLASH_RMK'] as String?)?.trim() ?? '',
      email: (json['EMAIL'] as String?)?.trim() ?? '',
      msmeNo: (json['MSME_NO'] as String?)?.trim() ?? '',
      companyType: (json['companytype'] as String?)?.trim() ?? '',
      custType: (json['custtype'] as num?)?.toInt() ?? 0,
      bankName: (json['bank_name'] as String?)?.trim() ?? '',
      bankAcNo: (json['bank_acno'] as String?)?.trim() ?? '',
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      syncTime: parseDate(json['_sync_time']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'NAME': name,
        'ATYPE': atype,
        'GCODE': gcode,
        'CITY1': city1,
        'STATION': station,
        'ADATIYA': adatiya,
        'MOBILE': mobile,
        'GSTIN': gstin,
        'ADDRESS1': address1,
        'ADDRESS2': address2,
        'TRANSPORT': transport,
        'DISTANCE': distance,
        'CONTACT': contact,
        'STATE1': state1,
        'PINNO': pinNo,
        'crdays': crDays,
        'TDSRATE': tdsRate,
        'FLASH_RMK': flashRmk,
        'EMAIL': email,
        'MSME_NO': msmeNo,
        'companytype': companyType,
        'custtype': custType,
        'bank_name': bankName,
        'bank_acno': bankAcNo,
        'CREATOR': author,
        'UPDATER': updater,
        'CREATETIME': createdOn?.toIso8601String(),
        'UPDATETIME': lastEdited?.toIso8601String(),
        '_sync_time': syncTime?.toIso8601String(),
      };

  // Domain Helper Getters
  String get fullAddress => [address1, address2, city1, state1, pinNo].where((s) => s.isNotEmpty).join(', ');
  bool get isCustomer => atype == 1;
  bool get isGreySupplier => atype == 2;
  bool get isBroker => atype == 12;
  bool get isJobWorker => atype == 14 || atype == 119;

  String get atypeDescription {
    switch (atype) {
      case 1:
        return 'SUNDRY DEBTORS';
      case 2:
        return 'CREDITORS FOR GREY';
      case 12:
        return 'CREDITORS FOR BROKERAGE';
      case 14:
        return 'CREDITORS FOR DYEING JOB';
      case 119:
        return 'CREDITORS FOR EMB JOB';
      case 106:
        return 'CREDITORS FOR EXPENSES';
      case 113:
        return 'CREDITORS FOR GOODS';
      case 112:
        return 'CREDITORS FOR PACKING';
      case 17:
        return 'STAFF';
      default:
        return 'TYPE #$atype';
    }
  }
}

/// Standardized UI Field Labels for `sq_MASTER`
abstract class SqMasterLabels {
  static const String code = 'Party Code';
  static const String name = 'Party Name';
  static const String atype = 'Account Type';
  static const String city1 = 'City';
  static const String station = 'Station Hub';
  static const String adatiya = 'Broker / Agent';
  static const String mobile = 'Mobile / WhatsApp';
  static const String gstin = 'GSTIN';
  static const String transport = 'Transport';
}

/// Dynamic Table UI Mapper Extension for `SqMasterModel`
extension SqMasterTableMapper on SqMasterModel {
  DyTableRowData toRowData([NumberFormat? currencyFmt]) {
    return DyTableRowData(
      id: code,
      voucherNo: code,
      partyName: name,
      designPattern: atypeDescription,
      quantity: city1.isNotEmpty ? city1 : 'Local',
      amount: mobile.isNotEmpty ? mobile : '-',
      amountValue: 0.0,
      status: gstin.isNotEmpty ? 'GST' : 'NON-GST',
      rawData: toJson(),
    );
  }

  static List<DyTableColumnSpec> get defaultColumns => const [
        DyTableColumnSpec(label: SqMasterLabels.code, key: 'voucherNo', flex: 3),
        DyTableColumnSpec(label: SqMasterLabels.name, key: 'partyName', flex: 4),
        DyTableColumnSpec(label: SqMasterLabels.atype, key: 'designPattern', flex: 3),
        DyTableColumnSpec(label: SqMasterLabels.city1, key: 'quantity', flex: 2),
        DyTableColumnSpec(label: SqMasterLabels.mobile, key: 'amount', flex: 3),
      ];
}
