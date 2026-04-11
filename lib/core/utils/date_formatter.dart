import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _shortDateFormat = DateFormat('dd/MM', 'pt_BR');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'pt_BR');
  static final _shortMonthYearFormat = DateFormat('MMM/yy', 'pt_BR');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _monthKeyFormat = DateFormat('yyyy-MM');
  static final _dayMonthFormat = DateFormat("dd 'de' MMMM", 'pt_BR');
  static final _fullFormat = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
  static final _timeFormat = DateFormat('HH:mm', 'pt_BR');

  static String format(DateTime date) => _dateFormat.format(date);
  static String formatShort(DateTime date) => _shortDateFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String formatShortMonthYear(DateTime date) =>
      _shortMonthYearFormat.format(date);
  static String formatApi(DateTime date) => _apiFormat.format(date);
  static String formatMonthKey(DateTime date) => _monthKeyFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonthFormat.format(date);
  static String formatFull(DateTime date) => _fullFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);

  static DateTime? parseApi(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return _apiFormat.parse(value);
    } catch (_) {
      return DateTime.tryParse(value);
    }
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    if (diff.inDays < 30) return 'há ${(diff.inDays / 7).floor()} sem';
    return format(date);
  }

  static String currentMonthKey() => _monthKeyFormat.format(DateTime.now());

  static DateTime monthKeyToDate(String monthKey) {
    final parts = monthKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  // Aliases for convenience
  static String shortDate(DateTime date) => formatShort(date);
  static String monthKey(DateTime date) => formatMonthKey(date);

  static const _monthAbbreviations = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  static String shortMonthFromKey(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      return _monthAbbreviations[date.month - 1];
    } catch (_) {
      return monthKey;
    }
  }

  static String monthYearFromKey(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      return formatMonthYear(date);
    } catch (_) {
      return monthKey;
    }
  }
}
