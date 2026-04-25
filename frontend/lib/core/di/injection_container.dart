import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_chicken/core/network/api_client.dart';
import 'package:golden_chicken/core/network/network_info.dart';
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
}
