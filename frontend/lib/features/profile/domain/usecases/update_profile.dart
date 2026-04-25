import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';
import 'package:golden_chicken/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, UserProfile>> call({
    String? fullName,
    String? phone,
    String? location,
  }) =>
      _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        location: location,
      );
}
