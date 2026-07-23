import 'package:flutter/material.dart';
import '../organism_design/theme.dart';

/// Legacy ERP Constants - These values are sourced from the IMMBE2627 schema
/// and are hardcoded here because they change very rarely in the textile business.
class LegacyConstants {
  // --- 1. COMPANY MASTER (sq_COMPMST) ---
  static const companies = {
    0: {'name': "AMBAJI SAREES*", 'cno': 1},
    1: {'name': "SAI SILK", 'cno': 2},
    2: {'name': "AMBAJI SAREES..", 'cno': 3},
    3: {
      'id': 3,
      'CNO': 4,
      'FAX1': null,
      'FIRM': "AMBAJI SAREES",
      'NAME': "PARTNERSHIP",
      'WARD': null,
      'CITY1': "SURAT",
      'COgrp': "AMBAJI SAREES",
      'EMAIL': "AMBAJISAREES2002@GMAIL.CO",
      'PANNO': "ABLFA2723Q",
      'RANGE': null,
      'cstno': null,
      'gstno': null,
      'CIN_NO': null,
      'CPINNO': "395010",
      'DIRECT': 0,
      'MOBILE': "9998351033",
      'PHONE1': "9998097475",
      'PHONE2': null,
      'PHONE3': null,
      'PHONE4': null,
      'STATE1': null,
      'CREATOR': null,
      'UPDATER': null,
      'cstdate': null,
      'einv_id': null,
      'gstdate': null,
      'ADDRESS1': "2001 TO 2005 HINDUSTAN TEXTILE CENTER-2",
      'ADDRESS2': "CANAL ROAD",
      'ADDRESS3': "HDFC BANK A/C NO - 50200031166612",
      'ADDRESS4': "HDFC0009027",
      'DIVISION': null,
      'OTHERRMK': null,
      'TDS_ACKS': null,
      'TDS_ACNO': "SRTA09475E",
      'C_MSME_NO': null,
      'SHORTNAME': "AS3",
      'einv_user': null,
      'excisereg': null,
      'CREATETIME': null,
      'UPDATETIME': null,
      '_sync_time': "2026-04-01 00:00:00",
      'ins_policy': "ICICI LOMBARD GIC LTD -2001/305512239/00/000",
      'COLLECTRATE': null,
      'COMPANYTYPE': "PARTNERSHIP",
      'C_MSME_TYPE': null,
      'lockOLDYEAR': false,
      'RETURN_DATE1': null,
      'RETURN_DATE2': null,
      'RETURN_DATE3': null,
      'RETURN_DATE4': null,
      'CEN_EXCISEREG': null,
      'COMPANY_GSTIN': "24ABLFA2723Q1Z6",
      'SECURITYLEVEL': 1,
      'tcs_applicable': "N",
      'OLD_BILLS_JV_DATE': null,
      'MULTI_MILL_CHALLAN': 0
    },
    4: {'name': "SUSHILKUMAR MITTAL HUF", 'cno': 5},
    5: {'name': "KRISHNADEVI MITTAL", 'cno': 6},
    6: {'name': "SUNILKUMAR MITTAL HUF", 'cno': 7},
    7: {'name': "SUNILKUMAR MITTAL", 'cno': 8},
    8: {'name': "RASHMI MITTAL", 'cno': 9},
    9: {'name': "SHUBHAM MITTAL", 'cno': 10},
    10: {'name': "AMBAJI..", 'cno': 11},
    11: {'name': "NITI MITTAL", 'cno': 12},
    12: {'name': "MAHEK MITTAL", 'cno': 13},
    13: {'name': "SUMAN SUSHILKUMAR MITTAL", 'cno': 14},
    14: {'name': "SUSHILKUMAR SADHURAM MITTAL", 'cno': 15},
    15: {'name': "AMBAJI SAREES.", 'cno': 16},
  };

  static Map<String, dynamic> get primaryCompany =>
      companies[3] as Map<String, dynamic>;

  // --- 2. BANKS (sq_banks) ---
  static const banks = {
    '1_1': {'name': "INDIAN BANK", 'cno': 1, 'id': 1},
    '2_1': {'name': "SUSHIL KUMAR MITTAL*", 'cno': 1, 'id': 2},
    '3_2': {'name': "INDIAN BANK", 'cno': 2, 'id': 3},
    '1_2': {'name': "SUMAN MITTAL", 'cno': 2, 'id': 1},
    '4_4': {'name': "HDFC BANK", 'cno': 4, 'id': 4},
    '18_4': {'name': "RASHMI MITTAL**", 'cno': 4, 'id': 18},
    '16_4': {'name': "SHUBHAM MITTAL*", 'cno': 4, 'id': 16},
    '7_4': {'name': "SMT. KRISHNADEVI MITTAL*", 'cno': 4, 'id': 7},
    '17_4': {'name': "SUMAN MITTAL", 'cno': 4, 'id': 17},
    '9_4': {'name': "SUNIL KUMAR MITTAL(HUF)*", 'cno': 4, 'id': 9},
    '6_4': {'name': "SUNIL KUMAR MITTAL*", 'cno': 4, 'id': 6},
    '8_4': {'name': "SUSHIL KUMAR MITTAL(H.U.F)*", 'cno': 4, 'id': 8},
    '5_4': {'name': "SUSHIL KUMAR MITTAL*", 'cno': 4, 'id': 5},
    '11_5': {'name': "SUSHIL KUMAR MITTAL(H.U.F)*", 'cno': 5, 'id': 11},
    '12_6': {'name': "SMT. KRISHNADEVI MITTAL*", 'cno': 6, 'id': 12},
    '13_7': {'name': "SUNIL KUMAR MITTAL(HUF)*", 'cno': 7, 'id': 13},
    '14_8': {'name': "SUNIL KUMAR MITTAL*", 'cno': 8, 'id': 14},
    '10_9': {'name': "RASHMI MITTAL**", 'cno': 9, 'id': 10},
    '14_10': {
      'id': 14,
      'cno': 10,
      'ACNO': null,
      'BANK': "HDFC BANK",
      'todate': null,
      'fromdate': null,
      'chqseries': null,
      'seriescode': 0,
      'RECONBALANCE': "170110.86",
      'internet_key': null
    },
    '15_10': {'name': "SHUBHAM MITTAL*", 'cno': 10, 'id': 15},
    '19_13': {'name': "HDFC BANK", 'cno': 13, 'id': 19},
  };

  static Map<String, dynamic> get mainBank =>
      banks['14_10'] as Map<String, dynamic>;

  // --- 3. ACCOUNT TYPES (sq_ATYPE) ---
  static const accountTypes = {
    1: {'name': "SUNDRY DEBTORS", 'letter': "C"},
    2: {'name': "CREDITORS FOR GREY", 'letter': "S"},
    3: {'name': "TRADING INCOMES", 'letter': "I"},
    4: {'name': "P & L EXPENSES", 'letter': "E"},
    5: {'name': "BANK", 'letter': "H"},
    6: {'name': "CASH", 'letter': "G"},
    7: {'name': "SALE", 'letter': "G"},
    8: {'name': "PURCHASE", 'letter': "G"},
    9: {'name': "LOANS", 'letter': "L"},
    10: {'name': "TRADING EXPENSES", 'letter': "E"},
    11: {'name': "FIXED ASSETS", 'letter': "F"},
    12: {'name': "CREDITORS FOR BROKERAGE", 'letter': "B"},
    13: {'name': "CAPITAL A/C", 'letter': "L"},
    14: {'name': "CREDITORS FOR DYEING JOB CHARG", 'letter': "M"},
    15: {'name': "MILL-EXCISE", 'letter': "X"},
    17: {'name': "STAFF", 'letter': "P"},
    18: {'name': "INVESTMENTS(APPLIED)", 'letter': "I"},
    19: {'name': "PROV. FOR TAX", 'letter': "I"},
    20: {'name': "LOANS AND ADVANCES", 'letter': "I"},
    21: {'name': "UNSECURED LOANS", 'letter': "L"},
    22: {'name': "RESERVES AND SURPLUS", 'letter': "R"},
    23: {'name': "CLOSING STOCK", 'letter': "X"},
    98: {'name': "STAFF ADVANCE", 'letter': "S"},
    99: {'name': "MODELLING PHOTO MATERIAL", 'letter': "O"},
    100: {'name': "PACKING MATERIAL", 'letter': "P"},
    102: {'name': "OPENING STOCK", 'letter': "G"},
    103: {'name': "VEHICLES", 'letter': "F"},
    104: {'name': "FURNITURE OF OFFICE", 'letter': "F"},
    105: {'name': "CREDITORS FOR OTHERS", 'letter': "H"},
    106: {'name': "CREDITORS FOR EXPENSES", 'letter': "H"},
    107: {'name': "P & L INCOMES", 'letter': "P"},
    108: {'name': "PREPAID EXPENSES", 'letter': "P"},
    109: {'name': "SECURED LOAN", 'letter': "H"},
    110: {'name': "TDS", 'letter': "T"},
    112: {'name': "CREDITORS FOR PACKING MAT.", 'letter': "H"},
    113: {'name': "CREDITORS FOR GOODS", 'letter': "H"},
    114: {'name': "CREDITORS FOR JOBWORK", 'letter': "H"},
    115: {'name': "CREDITORS FOR SERVICES", 'letter': "H"},
    116: {'name': "DEBTORS FOR OTHERS", 'letter': "H"},
    117: {'name': "SHARE APPLICATION", 'letter': "H"},
    118: {'name': "SHREE GANESHJI MAHARAJ", 'letter': "H"},
    119: {'name': "CREDITORS FOR EMB.JOB CHARGE", 'letter': "H"},
    120: {'name': "CREDITORS FOR MODELING", 'letter': "H"},
  };

  /// Universal mapping for account types (ATYPE) used in badges/chips
  static String getAccountTypeName(int atype) {
    switch (atype) {
      case 1:
        return 'Customer';
      case 2:
        return 'Weavers';
      case 12:
        return 'Agents';
      case 119:
        return 'Khata';
      case 113:
        return 'Suppliers';
      case 14:
        return 'Mills';
      case 112:
        return 'Packing';
      case 17:
        return 'Staff';
      case 106:
        return 'Expensors';
      default:
        return 'Others';
    }
  }

  /// Universal color mapping for account types based on categorical chart colors
  static Color getAccountTypeColor(BuildContext context, int atype) {
    final colors = OrganismTheme.colorsOf(context);
    switch (atype) {
      case 1:
        return colors.chart1; // Customers (Indigo)
      case 2:
        return colors.chart3; // Weavers (Green)
      case 12:
        return colors.chart6; // Agents (Violet)
      case 119:
        return colors.chart2; // Khata (Rose)
      case 113:
        return colors.chart8; // Suppliers (Orange)
      case 14:
        return colors.chart5; // Mills (Sky)
      case 112:
        return colors.chart9; // Packing (Teal)
      case 17:
        return colors.chart4; // Staff (Amber)
      case 106:
        return colors.chart7; // Expensors (Fuchsia)
      default:
        return colors.chart12; // Others (Slate)
    }
  }

  // --- 4. SERIES / PROCESS CODES (sq_SERIES) ---
  static const series = {
    '00': {
      'name': "OPENING BALANCE",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'B1': {
      'name': "BANK RECEIPT",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'B2': {
      'name': "BANK PAYMENT",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'C1': {
      'name': "CASH RECEIPT",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'C2': {
      'name': "CASH PAYMENT",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'E1': {
      'name': "EXPENSES",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'E2': {
      'name': "EXCISE",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'J1': {
      'name': "JOB WORK",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'J2': {
      'name': "JOURNAL",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'O': {
      'name': "WORK DESP ALL",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'O1': {
      'name': "SALES ORDERS",
      'in': "S1",
      'out': "S1",
      'billing': true,
      'stage_main': null
    },
    'O10': {
      'name': "WORK REC EMB CHALLAN",
      'in': "O9",
      'out': "P28",
      'billing': true,
      'stage_main': "O4"
    },
    'O11': {
      'name': "WORK DESP CHARAK CHALLAN",
      'in': "O6",
      'out': "O12",
      'billing': true,
      'stage_main': "O4"
    },
    'O12': {
      'name': "WORK REC CHARAK CHALLAN",
      'in': "O11",
      'out': "P29",
      'billing': true,
      'stage_main': "O4"
    },
    'O13': {
      'name': "FINISH PURCHASE ORDER",
      'in': null,
      'out': "P2",
      'billing': true,
      'stage_main': null
    },
    'O14': {
      'name': "LACE PURCHASE ORDER",
      'in': null,
      'out': "p11",
      'billing': true,
      'stage_main': null
    },
    'O3': {
      'name': "MULTI-CUTTING CARD",
      'in': null,
      'out': "O4",
      'billing': true,
      'stage_main': null
    },
    'O4': {
      'name': "WORK IN HOUSE CARD",
      'in': "O3",
      'out': null,
      'billing': true,
      'stage_main': "O4"
    },
    'O41': {
      'name': "STOCK TRANSFER",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'O42': {
      'name': "GODOWN TRANSFER",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'O43': {
      'name': "GODOWN INWARD",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'O44': {
      'name': "OPENING STOCK (FINISH)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'O45': {
      'name': "READY PRODUCT",
      'in': "O12",
      'out': null,
      'billing': true,
      'stage_main': "O4"
    },
    'O5': {
      'name': "WORK DESP STITCHING CHALLAN",
      'in': "O4",
      'out': "O6",
      'billing': true,
      'stage_main': "O4"
    },
    'O6': {
      'name': "WORK REC STITCHING CHALLAN",
      'in': "O5",
      'out': "O15",
      'billing': true,
      'stage_main': "O4"
    },
    'O7': {
      'name': "WORK DESP DIAMOND CHALLAN",
      'in': "O6",
      'out': "O8",
      'billing': true,
      'stage_main': "O4"
    },
    'O8': {
      'name': "WORK REC DIAMOND CHALLAN",
      'in': "O7",
      'out': "P27",
      'billing': true,
      'stage_main': "O4"
    },
    'O9': {
      'name': "WORK DESP EMB CHALLAN",
      'in': "O6",
      'out': "O10",
      'billing': true,
      'stage_main': "O4"
    },
    'OA': {
      'name': "ADVANCE RECEIPT VOUCHER",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'OF': {
      'name': "ADVANCE REFUND VOUCHER",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'OR': {
      'name': "REVERSE CHARGE SALES TO SELF",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P': {
      'name': "PURCHASES (ALL)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P1': {
      'name': "GREY PURCHASE",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'p11': {
      'name': "LACE PURCHASE",
      'in': "O14",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P2': {
      'name': "FINISH PURCHASE",
      'in': "O13",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P25': {
      'name': "SALES GOODS RETURN (BYMISTEK)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P26': {
      'name': "WORK REC STITCHING BILLS",
      'in': "O6",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P27': {
      'name': "WORK REC DIAMOND BILLS",
      'in': "O8",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P28': {
      'name': "WORK REC EMB BILLS",
      'in': "O10",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P29': {
      'name': "WORK REC CHARAK BILLS",
      'in': "O12",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P3': {
      'name': "SALES GOODS RETURN",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P32': {
      'name': "FINISH TOP DYED",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P4': {
      'name': "PACKING MATERIAL",
      'in': "O12",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P5': {
      'name': "WORK REC. BILL (OLD)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P6': {
      'name': "MODELLING PHOTO MATERIALS",
      'in': "P6",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P66': {
      'name': "CREDIT NOTE (TDS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P76': {
      'name': "PURCHASE BILLS (COMM)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P77': {
      'name': "CREDIT NOTE (TCS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P91': {
      'name': "CREDIT NOTE (ON SALES)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P92': {
      'name': "CREDIT NOTE (ON PURCHASES)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P93': {
      'name': "PURCHASE (GST INPUT SERVICES)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P94': {
      'name': "PURCHASE (GST CAPITAL GOODS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'P95': {
      'name': "PURCHASE (GST GENERAL GOODS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S': {
      'name': "SALES",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S1': {
      'name': "FINISH SALES",
      'in': "O1",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S2': {
      'name': "GREY PURCHASE RETURN",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S3': {
      'name': "PURCHASE RETURN",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S4': {
      'name': "CASH SALES",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S5': {
      'name': "GREY SALES",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S58': {
      'name': "FINISH SALES MULTY",
      'in': "O1",
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S6': {
      'name': "FENT SALES",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S66': {
      'name': "DEBIT NOTE (TDS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S77': {
      'name': "DEBIT NOTE (TCS)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S91': {
      'name': "DEBIT NOTE (ON SALES)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'S92': {
      'name': "DEBIT NOTE (ON PURCHASES)",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'T1': {
      'name': "TDS",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
    'V1': {
      'name': "VATAV",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'V2': {
      'name': "CLOSING ENTRIES (TRADING)",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'V3': {
      'name': "CLOSING ENTRIES (P & L)",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'V4': {
      'name': "VAT JV",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'V5': {
      'name': "COMMISSION JVS",
      'in': null,
      'out': null,
      'billing': false,
      'stage_main': null
    },
    'XX': {
      'name': "UNADJ PAYMENT",
      'in': null,
      'out': null,
      'billing': true,
      'stage_main': null
    },
  };

  /// Helper to get series name
  static String getSeriesName(String code) =>
      (series[code]?['name'] as String?) ?? 'UNKNOWN';

  /// Helper to check if a process is part of the Production Chain (O4 stage)
  static bool isProductionProcess(String code) {
    return [
      'O3',
      'O4',
      'O5',
      'O6',
      'O7',
      'O8',
      'O9',
      'O10',
      'O11',
      'O12',
      'O45'
    ].contains(code);
  }
}
