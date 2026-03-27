import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/connectivity/connectivity_cubit.dart';
import 'presentation/blocs/dashboard/dashboard_cubit.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';
import 'presentation/blocs/bill/bill_cubit.dart';
import 'presentation/blocs/income/income_cubit.dart';
import 'presentation/blocs/budget/budget_cubit.dart';
import 'presentation/blocs/savings/savings_cubit.dart';
import 'presentation/blocs/bank/bank_cubit.dart';
import 'presentation/blocs/card/card_cubit.dart';
import 'presentation/blocs/category/category_cubit.dart';
import 'presentation/blocs/notification/notification_cubit.dart';
import 'presentation/blocs/profile/profile_cubit.dart';

class FinancialiteApp extends StatelessWidget {
  const FinancialiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested())),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<ConnectivityCubit>()),
        BlocProvider(create: (_) => sl<DashboardCubit>()),
        BlocProvider(create: (_) => sl<TransactionBloc>()),
        BlocProvider(create: (_) => sl<BillCubit>()),
        BlocProvider(create: (_) => sl<IncomeCubit>()),
        BlocProvider(create: (_) => sl<BudgetCubit>()),
        BlocProvider(create: (_) => sl<SavingsCubit>()),
        BlocProvider(create: (_) => sl<BankCubit>()),
        BlocProvider(create: (_) => sl<CardCubit>()),
        BlocProvider(create: (_) => sl<CategoryCubit>()),
        BlocProvider(create: (_) => sl<NotificationCubit>()),
        BlocProvider(create: (_) => sl<ProfileCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Financialite',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(themeState.colorScheme),
            darkTheme: AppTheme.dark(themeState.colorScheme),
            themeMode: themeState.themeMode,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('pt', 'BR'),
          );
        },
      ),
    );
  }
}
