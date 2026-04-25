import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/profile/data/models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  const ProfileRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.profile,
    );
    return UserProfileModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: data,
    );
    return UserProfileModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
