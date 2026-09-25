import 'package:intl/intl.dart';

/// Date formatting utility for transaction grouping and display
class DateFormatter {
  DateFormatter._();

  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _groupFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

  /// Convert DateTime to API date format: "YYYY-MM-DD"
  static String toApiDate(DateTime dateTime) {
    return _apiFormat.format(dateTime);
  }

  /// Parse YYYY-MM-DD to DateTime
  static DateTime? parseApiDate(String dateString) {
    try {
      return _apiFormat.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Friendly human-readable group title for transaction lists
  static String relativeLabel(String dateString) {
    final parsed = parseApiDate(dateString);
    if (parsed == null) return dateString;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'HARI INI';
    } else if (difference == 1) {
      return 'KEMARIN';
    } else if (difference == -1) {
      return 'BESOK';
    } else if (target.year == now.year) {
      return DateFormat('EEEE, d MMM', 'id_ID').format(parsed).toUpperCase();
    } else {
      return _displayFormat.format(parsed).toUpperCase();
    }
  }

  /// Compact display date: "25 Sep 2026"
  static String formatDisplay(DateTime dateTime) {
    return _displayFormat.format(dateTime);
  }

  /// Full display date: "Jumat, 25 September 2026"
  static String formatFull(DateTime dateTime) {
    return _groupFormat.format(dateTime);
  }

  /// Full display date from API string
  static String formatFullFromApi(String dateString) {
    final parsed = parseApiDate(dateString);
    if (parsed == null) return dateString;
    return _groupFormat.format(parsed);
  }
}
