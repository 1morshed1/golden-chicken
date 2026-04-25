import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/profile/domain/usecases/get_profile.dart';
import 'package:golden_chicken/features/profile/domain/usecases/update_profile.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_event.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSaving());
    final result = await _updateProfile(
      fullName: event.fullName,
      phone: event.phone,
      location: event.location,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
