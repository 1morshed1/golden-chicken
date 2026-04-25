import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_bloc.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_event.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_state.dart';
import 'package:golden_chicken/features/market/presentation/widgets/price_hero_card.dart';
import 'package:golden_chicken/features/market/presentation/widgets/price_trend_chart.dart';

class MarketTabScreen extends StatelessWidget {
  const MarketTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarketBloc>()..add(const MarketDataRequested()),
      child: const _MarketTabView(),
    );
  }
}

class _MarketTabView extends StatelessWidget {
  const _MarketTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketInsights)),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) => switch (state) {
          MarketInitial() || MarketLoading() => const AppLoading(),
          MarketError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context
                  .read<MarketBloc>()
                  .add(const MarketDataRequested()),
            ),
          MarketLoaded() => _MarketBody(state: state),
        },
      ),
    );
  }
}

class _MarketBody extends StatelessWidget {
  const _MarketBody({required this.state});

  final MarketLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MarketBloc>().add(const MarketDataRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Dhaka Region — Live Prices',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: state.prices
                .take(3)
                .map(
                  (price) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: PriceHeroCard(price: price),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.updatedNow,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PeriodToggle(
            selected: state.selectedPeriod,
            onChanged: (period) =>
                context.read<MarketBloc>().add(MarketPeriodChanged(period)),
          ),
          const SizedBox(height: AppSpacing.md),
          PriceTrendChart(
            eggTrend: state.eggTrend,
            meatTrend: state.meatTrend,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.tip != null) _AiTipCard(tip: state.tip!),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const periods = [
      ('today', 'Today'),
      ('7d', '7 Days'),
      ('30d', '30 Days'),
    ];

    return Row(
      children: periods.map((p) {
        final isSelected = p.$1 == selected;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text(p.$2),
            selected: isSelected,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            side: isSelected ? BorderSide.none : const BorderSide(color: AppColors.border),
            onSelected: (_) => onChanged(p.$1),
          ),
        );
      }).toList(),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  const _AiTipCard({required this.tip});

  final MarketTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(26),
            AppColors.primary.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          const Text('💹', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI Confidence: ${tip.confidence}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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
