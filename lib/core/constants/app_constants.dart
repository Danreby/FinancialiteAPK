class AppConstants {
  AppConstants._();

  static const String appName = 'Financialite';
  static const String appVersion = '1.0.0';
  static const String locale = 'pt_BR';
  static const String currency = 'BRL';
  static const String currencySymbol = 'R\$';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String monthYearFormat = 'MM/yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';

  static const int paginationLimit = 20;
  static const int maxFileSize = 10 * 1024 * 1024;

  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf',
  ];

  static const List<String> transactionTypes = ['credit', 'debit'];
  static const List<String> billRecurrenceTypes = ['monthly', 'yearly', 'none'];
  static const List<String> incomeTypes = [
    'salary',
    'freelance',
    'investment',
    'rental',
    'benefit',
    'other',
    'pix',
  ];
}
