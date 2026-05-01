import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_chicken/core/network/api_client.dart';
import 'package:golden_chicken/core/network/network_info.dart';
import 'package:golden_chicken/core/services/audio_player_service.dart';
import 'package:golden_chicken/core/services/audio_recorder_service.dart';
import 'package:golden_chicken/core/services/camera_frame_service.dart';
import 'package:golden_chicken/core/services/offline_mutation_queue.dart';
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
import 'package:golden_chicken/features/insights/data/datasources/insights_remote_datasource.dart';
import 'package:golden_chicken/features/insights/data/repositories/insights_repository_impl.dart';
import 'package:golden_chicken/features/insights/domain/repositories/insights_repository.dart';
import 'package:golden_chicken/features/insights/domain/usecases/acknowledge_insight.dart';
import 'package:golden_chicken/features/insights/domain/usecases/get_insights.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:golden_chicken/features/live_ai/data/datasources/live_ai_websocket_datasource.dart';
import 'package:golden_chicken/features/live_ai/data/repositories/live_ai_repository_impl.dart';
import 'package:golden_chicken/features/live_ai/domain/repositories/live_ai_repository.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_bloc.dart';
import 'package:golden_chicken/features/market/data/datasources/market_remote_datasource.dart';
import 'package:golden_chicken/features/market/data/repositories/market_repository_impl.dart';
import 'package:golden_chicken/features/market/domain/repositories/market_repository.dart';
import 'package:golden_chicken/features/market/domain/usecases/get_market_prices.dart';
import 'package:golden_chicken/features/market/domain/usecases/get_price_trend.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_bloc.dart';
import 'package:golden_chicken/features/production/data/datasources/production_remote_datasource.dart';
import 'package:golden_chicken/features/production/data/repositories/production_repository_impl.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_chicken_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_egg_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_flock_overview.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_sheds.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_bloc.dart';
import 'package:golden_chicken/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:golden_chicken/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:golden_chicken/features/profile/domain/repositories/profile_repository.dart';
import 'package:golden_chicken/features/profile/domain/usecases/get_profile.dart';
import 'package:golden_chicken/features/profile/domain/usecases/update_profile.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:golden_chicken/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:golden_chicken/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:golden_chicken/features/tasks/domain/repositories/task_repository.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/complete_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/create_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/get_tasks.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_bloc.dart';
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
    ..registerLazySingleton(() => sl<ApiClient>().dio)
    ..registerLazySingleton(
      () => OfflineMutationQueue(
        dio: sl(),
        connectivity: sl(),
      ),
    );

  await sl<OfflineMutationQueue>().init();

  // Auth
  _initAuth();

  // Chat
  _initChat();

  // Health
  _initHealth();

  // Production
  _initProduction();

  // Market
  _initMarket();

  // Tasks
  _initTasks();

  // Profile
  _initProfile();

  // Insights
  _initInsights();

  // Live AI
  _initLiveAi();
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
    ..registerLazySingleton(() => GetSheds(sl()))
    ..registerFactory(
      () => ProductionBloc(
        getFlockOverview: sl(),
        addEggRecord: sl(),
        addChickenRecord: sl(),
        getSheds: sl(),
      ),
    );
}

void _initMarket() {
  sl
    ..registerLazySingleton<MarketRemoteDatasource>(
      () => MarketRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<MarketRepository>(
      () => MarketRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetMarketPrices(sl()))
    ..registerLazySingleton(() => GetPriceTrend(sl()))
    ..registerFactory(
      () => MarketBloc(
        getMarketPrices: sl(),
        getPriceTrend: sl(),
      ),
    );
}

void _initTasks() {
  sl
    ..registerLazySingleton<TaskRemoteDatasource>(
      () => TaskRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetTasks(sl()))
    ..registerLazySingleton(() => CreateTask(sl()))
    ..registerLazySingleton(() => CompleteTask(sl()))
    ..registerFactory(
      () => TaskBloc(
        getTasks: sl(),
        createTask: sl(),
        completeTask: sl(),
      ),
    );
}

void _initProfile() {
  sl
    ..registerLazySingleton<ProfileRemoteDatasource>(
      () => ProfileRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerFactory(
      () => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
      ),
    );
}

void _initInsights() {
  sl
    ..registerLazySingleton<InsightsRemoteDatasource>(
      () => InsightsRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<InsightsRepository>(
      () => InsightsRepositoryImpl(remoteDatasource: sl()),
    )
    ..registerLazySingleton(() => GetInsights(sl()))
    ..registerLazySingleton(() => AcknowledgeInsight(sl()))
    ..registerFactory(
      () => InsightsBloc(
        getInsights: sl(),
        acknowledgeInsight: sl(),
      ),
    );
}

void _initLiveAi() {
  sl
    ..registerLazySingleton(LiveAiWebSocketDatasource.new)
    ..registerLazySingleton<LiveAiRepository>(
      () => LiveAiRepositoryImpl(datasource: sl()),
    )
    ..registerFactory(AudioRecorderService.new)
    ..registerFactory(AudioPlayerService.new)
    ..registerFactory(CameraFrameService.new)
    ..registerFactory(
      () => LiveAiBloc(
        repository: sl(),
        secureStorage: sl(),
        audioRecorder: sl(),
        audioPlayer: sl(),
        cameraFrameService: sl(),
      ),
    );
}
