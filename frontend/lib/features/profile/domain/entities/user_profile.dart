import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.location,
    this.avatarUrl,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Silver',
    this.nextTierPoints = 2000,
    this.notificationCount = 0,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? location;
  final String? avatarUrl;
  final int loyaltyPoints;
  final String loyaltyTier;
  final int nextTierPoints;
  final int notificationCount;

  int get pointsToNextTier => nextTierPoints - loyaltyPoints;

  @override
  List<Object?> get props => [id, fullName, email, loyaltyPoints];
}
