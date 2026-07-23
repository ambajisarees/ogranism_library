import 'package:intl/intl.dart';

/// Centralized formatting DNA for the Ambaji ERP.
/// Standardizes Indian-regional numbering, currency, and local textile units.
class OrganismFormat {
  // --- CURRENCY & NUMBERS (en_IN) ---

  /// Standard Indian currency format: ₹1,23,456.78
  static String currency(double value, {int decimals = 2}) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimals,
    );
    return format.format(value);
  }

  /// Standard Indian number grouping: 1,45,000
  static String number(num value, {int decimals = 0}) {
    final format = NumberFormat.decimalPattern('en_IN');
    if (decimals > 0) {
      format.minimumFractionDigits = decimals;
      format.maximumFractionDigits = decimals;
    }
    return format.format(value);
  }

  /// Compact Indian currency: ₹1.23L / ₹1.23Cr
  static String compactCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    }
    return currency(value, decimals: 0);
  }

  // --- TEMPORAL DNA (Indian Fiscal Standards) ---

  /// Date format: DD/MM/YYYY
  static String date(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  /// Date format: 10 Apr 2026
  static String dateLong(DateTime d) {
    return DateFormat('dd MMM yyyy').format(d);
  }

  /// Date & Time: DD/MM/YYYY HH:mm
  static String dateTime(DateTime d) {
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  /// Indian Financial Year: "FY 2025-26" (April to March)
  static String financialYear(DateTime d) {
    int startYear = (d.month >= 4) ? d.year : d.year - 1;
    int endYearShort = (startYear + 1) % 100;
    return 'FY $startYear-${endYearShort.toString().padLeft(2, '0')}';
  }

  /// Returns the date range for a given "FY 2025-26" string
  static (DateTime start, DateTime end) financialYearRange(String fy) {
    final parts = fy.replaceFirst('FY ', '').split('-');
    final startYear = int.parse(parts[0]);
    final start = DateTime(startYear, 4, 1);
    final end = DateTime(startYear + 1, 3, 31, 23, 59, 59);
    return (start, end);
  }

  // --- TEXTILE DISCIPLINE (Units) ---

  /// Formats meters: "123.45 m"
  static String meters(double value, {int decimals = 2}) {
    return '${number(value, decimals: decimals)} m';
  }

  /// Generic quantity: "50 pcs"
  static String quantity(double value, String unit) {
    return '${number(value)} $unit';
  }
}
