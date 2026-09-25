import 'package:intl/intl.dart';

/// Formatter for Indonesian Rupiah (IDR) following strict editorial standard
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Standard format: "Rp 1.250.000"
  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Compact format for small spaces: "Rp 1,2 jt" or "Rp 850 rb"
  static String formatCompact(num amount) {
    if (amount >= 1000000000) {
      final value = (amount / 1000000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return 'Rp $value M';
    } else if (amount >= 1000000) {
      final value = (amount / 1000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return 'Rp $value Jt';
    } else if (amount >= 1000) {
      final value = (amount / 1000).toStringAsFixed(0);
      return 'Rp $value Rb';
    }
    return format(amount);
  }

  /// Parses digits from raw text input (e.g. "50.000" or "Rp 50.000" -> 50000)
  static num parse(String rawText) {
    final clean = rawText.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return 0;
    return num.tryParse(clean) ?? 0;
  }

  /// Alias for parse
  static num parseDigits(String rawText) => parse(rawText);
}
