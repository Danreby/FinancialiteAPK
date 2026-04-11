import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/pages/app_shell.dart';
import '../../presentation/pages/more/more_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/transactions/transactions_page.dart';
import '../../presentation/pages/transactions/transaction_form_page.dart';
import '../../presentation/pages/bills/bills_page.dart';
import '../../presentation/pages/income/income_page.dart';
import '../../presentation/pages/budget/budget_page.dart';
import '../../presentation/pages/savings/savings_page.dart';
import '../../presentation/pages/bank/bank_accounts_page.dart';
import '../../presentation/pages/bank/bank_transfer_page.dart';
import '../../presentation/pages/cards/cards_page.dart';
import '../../presentation/pages/categories/categories_page.dart';
import '../../presentation/pages/notifications/notifications_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/reports/reports_page.dart';
import '../../presentation/pages/reports/report_category_page.dart';
import '../../presentation/pages/reports/report_monthly_page.dart';
import '../../presentation/pages/reports/report_evolution_page.dart';
import '../../presentation/pages/faturas/faturas_page.dart';
import '../../presentation/pages/extract/extract_page.dart';
import '../../presentation/pages/projections/projections_page.dart';

/// Converts the [AuthBloc] stream into a [ChangeNotifier] so GoRouter
/// re-evaluates its redirect whenever the auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthRefreshNotifier(AuthBloc authBloc) {
    _sub = authBloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static GoRouter get router {
    return _router ??= _createRouter();
  }

  static GoRouter _createRouter() {
    final authBloc = sl<AuthBloc>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: _AuthRefreshNotifier(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuth = authState is AuthAuthenticated;
        final isLoading = authState is AuthInitial || authState is AuthLoading;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/splash';

        // While checking auth, stay on splash
        if (isLoading && isSplash) return null;
        // Auth check done → redirect away from splash
        if (isSplash && isAuth) return '/dashboard';
        if (isSplash && !isAuth) return '/login';
        // Normal guards
        if (!isAuth && !isAuthRoute) return '/login';
        if (isAuth && isAuthRoute) return '/dashboard';
        return null;
      },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TransactionsPage()),
          ),
          GoRoute(
            path: '/transactions/new',
            builder: (context, state) => const TransactionFormPage(),
          ),
          GoRoute(
            path: '/transactions/:id',
            builder: (context, state) => TransactionFormPage(
              transactionId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: '/bills',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BillsPage()),
          ),
          GoRoute(
            path: '/income',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: IncomePage()),
          ),
          GoRoute(
            path: '/budget',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BudgetPage()),
          ),
          GoRoute(
            path: '/savings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SavingsPage()),
          ),
          GoRoute(
            path: '/bank-accounts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BankAccountsPage()),
          ),
          GoRoute(
            path: '/bank-transfer',
            builder: (context, state) => const BankTransferPage(),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MorePage()),
          ),
          GoRoute(
            path: '/cards',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CardsPage()),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CategoriesPage()),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsPage()),
          ),
          GoRoute(
            path: '/reports/categories',
            builder: (context, state) => const ReportCategoryPage(),
          ),
          GoRoute(
            path: '/reports/monthly',
            builder: (context, state) => const ReportMonthlyPage(),
          ),
          GoRoute(
            path: '/reports/evolution',
            builder: (context, state) => const ReportEvolutionPage(),
          ),
          GoRoute(
            path: '/faturas',
            builder: (context, state) => const FaturasPage(),
          ),
          GoRoute(
            path: '/extract',
            builder: (context, state) => const ExtractPage(),
          ),
          GoRoute(
            path: '/projections',
            builder: (context, state) => const ProjectionsPage(),
          ),
        ],
      ),
    ],
    );
  }
}
