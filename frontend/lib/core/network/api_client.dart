import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/core/network/api_interceptors.dart';

class ApiClient {
  ApiClient({required FlutterSecureStorage secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([
        AuthInterceptor(secureStorage: secureStorage),
        LoggingInterceptor(),
        ErrorInterceptor(),
      ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
