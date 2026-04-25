import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving();
}
