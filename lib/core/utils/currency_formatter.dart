import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _brFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
  static final _compactFormat = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

  static String format(double value) => _brFormat.format(value);

  static String formatCompact(double value) {
    if (value.abs() >= 1000) return _compactFormat.format(value);
    return _brFormat.format(value);
  }

  static String formatSigned(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${_brFormat.format(value)}';
  }

  static double parse(String value) {
    try {
      final cleaned = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  static String toInputFormat(double value) {
    return _brFormat.format(value).replaceAll('R\$ ', '').replaceAll('R\$', '');
  }
}
