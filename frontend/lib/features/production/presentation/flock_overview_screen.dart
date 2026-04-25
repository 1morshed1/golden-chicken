import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_bloc.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_event.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_state.dart';
import 'package:golden_chicken/features/production/presentation/widgets/production_stat_card.dart';

class FlockOverviewScreen extends StatelessWidget {
  const FlockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProductionBloc>()..add(const FlockOverviewRequested()),
      child: const _FlockOverviewView(),
    );
  }
}

class _FlockOverviewView extends StatelessWidget {
  const _FlockOverviewView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.flockOverview)),
      body: BlocBuilder<ProductionBloc, ProductionState>(
        builder: (context, state) => switch (state) {
          ProductionInitial() ||
          ProductionLoading() =>
            const AppLoading(),
          ProductionError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context
                  .read<ProductionBloc>()
                  .add(const FlockOverviewRequested()),
            ),
          ProductionLoaded(:final summary) =>
            _FlockOverviewBody(summary: summary),
          RecordSaving() => const AppLoading(),
          RecordSaved() => const AppLoading(),
        },
      ),
    );
  }
}

class _FlockOverviewBody extends StatelessWidget {
  const _FlockOverviewBody({required this.summary});

  final FlockSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<ProductionBloc>()
            .add(const FlockOverviewRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (summary.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'AI Auto-Updated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ProductionStatCard(
                  icon: Icons.pets,
                  label: l10n.totalBirds,
                  value: '${summary.totalBirds}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProductionStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: l10n.alerts,
                  value: '${summary.alertCount}',
                  valueColor: summary.alertCount > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProductionStatCard(
                  icon: Icons.calendar_today,
                  label: l10n.avgAge,
                  value: '${summary.avgAgeDays}d',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AiScoreBadge(score: summary.aiScore),
          const SizedBox(height: AppSpacing.lg),
          if (summary.alerts.isNotEmpty) ...[
            Text(
              l10n.alerts,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...summary.alerts.map(
              (alert) => _AlertCard(alert: alert),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            l10n.todaysFeedPlan,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...summary.feedPlan.map(
            (item) => _FeedPlanRow(item: item),
          ),
        ],
      ),
    );
  }
}

class _AiScoreBadge extends StatelessWidget {
  const _AiScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AI Score: $score%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final FarmAlert alert;

  @override
  Widget build(BuildContext context) {
    final isWarning = alert.type == 'warning' || alert.type == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isWarning ? AppColors.warning : AppColors.info).withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color:
              (isWarning ? AppColors.warning : AppColors.info).withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isWarning ? AppColors.warning : AppColors.info,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (alert.description != null)
                  Text(
                    alert.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPlanRow extends StatelessWidget {
  const _FeedPlanRow({required this.item});

  final FeedPlanItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${item.amountKg} kg',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
