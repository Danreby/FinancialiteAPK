import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../security/secure_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/bill_repository_impl.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/repositories/bank_repository_impl.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/services/sync_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/bank_repository.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../../presentation/blocs/connectivity/connectivity_cubit.dart';
import '../../presentation/blocs/dashboard/dashboard_cubit.dart';
import '../../presentation/blocs/transaction/transaction_bloc.dart';
import '../../presentation/blocs/bill/bill_cubit.dart';
import '../../presentation/blocs/income/income_cubit.dart';
import '../../presentation/blocs/budget/budget_cubit.dart';
import '../../presentation/blocs/savings/savings_cubit.dart';
import '../../presentation/blocs/bank/bank_cubit.dart';
import '../../presentation/blocs/card/card_cubit.dart';
import '../../presentation/blocs/category/category_cubit.dart';
import '../../presentation/blocs/notification/notification_cubit.dart';
import '../../presentation/blocs/profile/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Interceptors
  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => ConnectivityInterceptor(sl()));

  // API Client
  sl.registerLazySingleton(() => ApiClient(
        authInterceptor: sl(),
        connectivityInterceptor: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<BillRepository>(
      () => BillRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<IncomeRepository>(
      () => IncomeRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<BankRepository>(
      () => BankRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<SavingsRepository>(
      () => SavingsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<CardRepository>(
      () => CardRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl(), sl()));

  // Services
  sl.registerLazySingleton(() => SyncService(sl(), sl()));

  // BLoCs / Cubits
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => ConnectivityCubit(sl()));
  sl.registerLazySingleton(() => DashboardCubit(sl()));
  sl.registerLazySingleton(() => TransactionBloc(sl()));
  sl.registerLazySingleton(() => BillCubit(sl()));
  sl.registerLazySingleton(() => IncomeCubit(sl()));
  sl.registerLazySingleton(() => BudgetCubit(sl()));
  sl.registerLazySingleton(() => SavingsCubit(sl()));
  sl.registerLazySingleton(() => BankCubit(sl()));
  sl.registerLazySingleton(() => CardCubit(sl()));
  sl.registerLazySingleton(() => CategoryCubit(sl()));
  sl.registerLazySingleton(() => NotificationCubit(sl()));
  sl.registerLazySingleton(() => ProfileCubit(sl()));
}
