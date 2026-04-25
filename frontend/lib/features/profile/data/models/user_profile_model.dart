import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    super.location,
    super.avatarUrl,
    super.loyaltyPoints,
    super.loyaltyTier,
    super.nextTierPoints,
    super.notificationCount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] as String?) ?? '',
      location: json['location'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      loyaltyTier: (json['loyalty_tier'] as String?) ?? 'Silver',
      nextTierPoints: (json['next_tier_points'] as num?)?.toInt() ?? 2000,
      notificationCount:
          (json['notification_count'] as num?)?.toInt() ?? 0,
    );
  }
}
