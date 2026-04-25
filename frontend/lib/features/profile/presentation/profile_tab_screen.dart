import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/l10n/locale_cubit.dart';
import 'package:golden_chicken/core/theme/theme_cubit.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_event.dart';
import 'package:golden_chicken/features/profile/domain/entities/user_profile.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_event.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_state.dart';

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: const _ProfileTabView(),
    );
  }
}

class _ProfileTabView extends StatelessWidget {
  const _ProfileTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileInitial() || ProfileLoading() => const AppLoading(),
          ProfileSaving() => const AppLoading(),
          ProfileError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileRequested()),
            ),
          ProfileLoaded(:final profile) => _ProfileBody(profile: profile),
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _AvatarSection(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        _LoyaltyCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle(title: 'Preferences'),
        const SizedBox(height: AppSpacing.sm),
        _PreferenceRow(
          icon: Icons.language,
          label: 'Language',
          trailing: Text(
            Localizations.localeOf(context).languageCode == 'bn'
                ? 'বাংলা'
                : 'English',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => context.read<LocaleCubit>().toggleLocale(),
        ),
        _PreferenceRow(
          icon: Icons.dark_mode_outlined,
          label: l10n.darkMode,
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            activeThumbColor: AppColors.primary,
            onChanged: (_) => context.read<ThemeCubit>().toggleDarkMode(),
          ),
          onTap: () => context.read<ThemeCubit>().toggleDarkMode(),
        ),
        _PreferenceRow(
          icon: Icons.notifications_outlined,
          label: l10n.notifications,
          trailing: Badge(
            label: Text('${profile.notificationCount}'),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle(title: 'Data & History'),
        const SizedBox(height: AppSpacing.sm),
        _PreferenceRow(
          icon: Icons.chat_outlined,
          label: l10n.chatHistory,
          onTap: () {},
        ),
        _PreferenceRow(
          icon: Icons.download_outlined,
          label: l10n.exportFarmData,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.xl),
        _PreferenceRow(
          icon: Icons.info_outline,
          label: l10n.about,
          onTap: () {},
        ),
        _PreferenceRow(
          icon: Icons.code,
          label: l10n.version,
          trailing: const Text(
            '1.0.0',
            style: TextStyle(color: AppColors.textTertiary),
          ),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.lg),
        _PreferenceRow(
          icon: Icons.logout,
          label: l10n.logout,
          iconColor: AppColors.error,
          labelColor: AppColors.error,
          onTap: () =>
              context.read<AuthBloc>().add(const AuthLogoutRequested()),
        ),
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withAlpha(26),
              child: Text(
                profile.fullName.isNotEmpty
                    ? profile.fullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.fullName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          profile.phone,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        if (profile.location != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                profile.location!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.loyaltyGradientStart,
            AppColors.loyaltyGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.loyaltyPoints,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  profile.loyaltyTier,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${profile.loyaltyPoints} pts',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${profile.pointsToNextTier} points to reach Gold',
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
