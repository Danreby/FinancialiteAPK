class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://financialite.rolims.com';
  static const String apiUrl = '$baseUrl/api/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String user = '/auth/user';

  static const String dashboard = '/dashboard';
  static const String projections = '/projections';

  static const String transactions = '/transacoes';
  static const String transactionStats = '/transacoes/stats';
  static const String transactionInsights = '/transacoes/insights';
  static const String transactionTopSpending = '/transacoes/top-spending';
  static const String transactionExport = '/transacoes/export';
  static const String transactionPayMonth = '/transacoes/pay-month';
  static const String transactionFaturas = '/transacoes/faturas';

  static const String incomes = '/incomes';
  static const String incomeSummary = '/incomes/summary';

  static const String bills = '/bills';
  static const String billsUpcoming = '/bills/upcoming';

  static const String budgets = '/budgets';
  static const String budgetsCurrent = '/budgets/current';
  static const String budgetsGetOrCreate = '/budgets/get-or-create-current';

  static const String savings = '/savings';
  static const String savingsSummary = '/savings/summary';

  static const String bankAccounts = '/bank-accounts';
  static const String bankAccountsBanks = '/bank-accounts/banks';
  static const String bankAccountsStats = '/bank-accounts/stats';
  static const String bankTransfers = '/bank-transfers';

  static const String categories = '/categories';

  static const String cards = '/cards';
  static const String cardsAvailable = '/cards/available';
  static const String cardResources = '/card-resources';
  static const String cardUsers = '/card-users';
  static const String cardUsersStats = '/card-users/stats';

  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationsClearAll = '/notifications/clear-all';

  static const String profile = '/profile';
  static const String profileTheme = '/profile/theme';
  static const String profilePassword = '/profile/password';

  static const String anexos = '/anexos';
  static const String anexosStats = '/anexos/stats';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
