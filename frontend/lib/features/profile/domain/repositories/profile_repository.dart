import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? location,
  });
}
