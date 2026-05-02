import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/auth/data/models/auth_response_model.dart';
import 'package:golden_chicken/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<({String accessToken, String refreshToken})> refreshToken(
    String refreshToken,
  );

  Future<void> logout(String refreshToken);

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<({String accessToken, String refreshToken})> refreshToken(
    String refreshToken,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return (
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      ApiEndpoints.logoutEndpoint,
      data: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.profile,
    );
    return UserModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
