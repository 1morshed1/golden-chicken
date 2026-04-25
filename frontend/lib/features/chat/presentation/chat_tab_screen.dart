import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_drawer.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_state.dart';
import 'package:golden_chicken/features/chat/presentation/widgets/ai_status_card.dart';
import 'package:golden_chicken/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:golden_chicken/features/chat/presentation/widgets/quick_action_chips.dart';
import 'package:golden_chicken/features/chat/presentation/widgets/tip_banner.dart';

class ChatTabScreen extends StatelessWidget {
  const ChatTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated
                ? state.user.fullName
                : l10n.appName;
            return Text(name);
          },
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${state.user.loyaltyPoints}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const AiStatusCard(),
                const SizedBox(height: AppSpacing.md),
                const TipBanner(
                  icon: Icons.water_drop,
                  iconColor: AppColors.info,
                  title: 'Water Check',
                  subtitle: 'Clean drinkers twice daily',
                ),
                const SizedBox(height: AppSpacing.sm),
                const TipBanner(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.warning,
                  title: 'Biosec',
                  subtitle: 'Disinfect entry points',
                ),
                const SizedBox(height: AppSpacing.lg),
                _AiMessageBubble(),
                const SizedBox(height: AppSpacing.lg),
                QuickActionChips(
                  onChipTapped: (prompt) => context.push(
                    '/chat/detail?prompt=${Uri.encodeComponent(prompt)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _LiveAiButton(l10n: l10n),
              ],
            ),
          ),
          ChatInputBar(
            onSubmit: (String text) => context.push(
              '/chat/detail?prompt=${Uri.encodeComponent(text)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.aiBubble,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your flock is looking healthy today! Feed consumption '
              'is on track and egg production has increased by 3% '
              'this week. Keep up the good work!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveAiButton extends StatelessWidget {
  const _LiveAiButton({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            const Icon(Icons.videocam, color: Colors.white, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveAi,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Voice + Camera AI Session',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
