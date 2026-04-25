import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

final class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated({this.fullName, this.phone, this.location});

  final String? fullName;
  final String? phone;
  final String? location;

  @override
  List<Object?> get props => [fullName, phone, location];
}
