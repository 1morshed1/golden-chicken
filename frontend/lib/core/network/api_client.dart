import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/core/network/api_interceptors.dart';

class ApiClient {
  ApiClient({required FlutterSecureStorage secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    )
      ..interceptors.addAll([
          AuthInterceptor(secureStorage: secureStorage),
          LoggingInterceptor(),
          ErrorInterceptor(),
        ])
      ..httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient()
              ..idleTimeout = const Duration(seconds: 5);
            return client;
          },
        );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
