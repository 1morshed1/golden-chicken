import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';
import 'package:golden_chicken/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(
      {required ProfileRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final ProfileRemoteDatasource _remote;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      return Right(profile);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? location,
  }) async {
    try {
      final data = <String, dynamic>{
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
      };
      final profile = await _remote.updateProfile(data);
      return Right(profile);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const AuthFailure();
    return ServerFailure(
      e.response?.data is Map<String, dynamic>
          ? ((e.response!.data as Map<String, dynamic>)['detail']
                  as String?) ??
              'Server error'
          : 'Server error',
    );
  }
}
