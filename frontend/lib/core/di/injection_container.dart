import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_chicken/core/network/api_client.dart';
import 'package:golden_chicken/core/network/network_info.dart';
import 'package:golden_chicken/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:golden_chicken/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:golden_chicken/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:golden_chicken/features/auth/domain/repositories/auth_repository.dart';
import 'package:golden_chicken/features/auth/domain/usecases/login_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/logout_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/register_usecase.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:golden_chicken/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:golden_chicken/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:golden_chicken/features/chat/domain/repositories/chat_repository.dart';
import 'package:golden_chicken/features/chat/domain/usecases/create_new_chat.dart';
import 'package:golden_chicken/features/chat/domain/usecases/get_chat_history.dart';
import 'package:golden_chicken/features/chat/domain/usecases/send_message.dart';
import 'package:golden_chicken/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:golden_chicken/features/health_center/data/datasources/health_remote_datasource.dart';
import 'package:golden_chicken/features/health_center/data/repositories/health_repository_impl.dart';
import 'package:golden_chicken/features/health_center/domain/repositories/health_repository.dart';
import 'package:golden_chicken/features/health_center/domain/usecases/ask_health_question.dart';
import 'package:golden_chicken/features/health_center/domain/usecases/get_health_tabs.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_bloc.dart';
import 'package:golden_chicken/features/production/data/datasources/production_remote_datasource.dart';
import 'package:golden_chicken/features/production/data/repositories/production_repository_impl.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_chicken_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_egg_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_flock_overview.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPrefs = await SharedPreferences.getInstance();

  sl
    ..registerLazySingleton(() => sharedPrefs)
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    )
    ..registerLazySingleton(() => ApiClient(secureStorage: sl()))
    ..registerLazySingleton(() => sl<ApiClient>().dio);

  // Auth
  _initAuth();

  // Chat
  _initChat();

  // Health
  _initHealth();

  // Production
  _initProduction();
}

void _initAuth() {
  sl
    // Datasources
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasourceImpl(sl<FlutterSecureStorage>()),
    )
    // Repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDatasource: sl(),
        localDatasource: sl(),
      ),
    )
    // Use cases
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => RefreshTokenUseCase(sl()))
    // BLoC
    ..registerFactory(
      () => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        refreshTokenUseCase: sl(),
      ),
    );
}

void _initHealth() {
  sl
    ..registerLazySingleton<HealthRemoteDatasource>(
      () => HealthRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<HealthRepository>(
      () => HealthRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetHealthTabs(sl()))
    ..registerLazySingleton(() => AskHealthQuestion(sl()))
    ..registerFactory(
      () => HealthBloc(
        getHealthTabs: sl(),
        askHealthQuestion: sl(),
      ),
    );
}

void _initChat() {
  sl
    ..registerLazySingleton<ChatRemoteDatasource>(
      () => ChatRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => CreateNewChat(sl()))
    ..registerLazySingleton(() => GetChatHistory(sl()))
    ..registerLazySingleton(() => SendMessage(sl()))
    ..registerFactory(
      () => ChatBloc(
        createNewChat: sl(),
        getChatHistory: sl(),
        sendMessage: sl(),
      ),
    );
}

void _initProduction() {
  sl
    ..registerLazySingleton<ProductionRemoteDatasource>(
      () => ProductionRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<ProductionRepository>(
      () => ProductionRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetFlockOverview(sl()))
    ..registerLazySingleton(() => AddEggRecord(sl()))
    ..registerLazySingleton(() => AddChickenRecord(sl()))
    ..registerFactory(
      () => ProductionBloc(
        getFlockOverview: sl(),
        addEggRecord: sl(),
        addChickenRecord: sl(),
      ),
    );
}
