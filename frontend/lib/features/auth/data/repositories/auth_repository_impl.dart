import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:golden_chicken/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:golden_chicken/features/auth/domain/entities/user.dart';
import 'package:golden_chicken/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
  })  : _remote = remoteDatasource,
        _local = localDatasource;

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        email: email,
        password: password,
      );
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return Right(response.user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return Right(response.user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken() async {
    try {
      final token = await _local.getRefreshToken();
      if (token == null) return const Left(AuthFailure('No refresh token'));

      final tokens = await _remote.refreshToken(token);
      await _local.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final user = await _remote.getCurrentUser();
      await _local.saveUser(user);
      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await _local.getRefreshToken();
      if (token != null) {
        await _remote.logout(token);
      }
      await _local.clearAll();
      return const Right(null);
    } on DioException {
      await _local.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _remote.getCurrentUser();
      await _local.saveUser(user);
      return Right(user);
    } on DioException catch (e) {
      final cached = await _local.getCachedUser();
      if (cached != null) return Right(cached);
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await _local.getAccessToken();
    return token != null;
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const AuthFailure('Invalid credentials');
    }
    if (statusCode == 409) {
      return const AuthFailure('Account already exists');
    }
    if (statusCode == 422 && data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return ValidationFailure(detail);
    }

    return ServerFailure(
      data is Map<String, dynamic>
          ? (data['detail'] as String?) ?? 'Server error'
          : 'Server error',
    );
  }
}
