import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.location,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Silver',
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? location;
  final int loyaltyPoints;
  final String loyaltyTier;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        avatarUrl,
        location,
        loyaltyPoints,
        loyaltyTier,
      ];
}
