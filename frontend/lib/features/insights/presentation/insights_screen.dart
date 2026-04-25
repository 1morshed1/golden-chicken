import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_event.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_state.dart';
import 'package:golden_chicken/features/insights/presentation/widgets/insight_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InsightsBloc>()..add(const InsightsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Farm Insights')),
        body: BlocBuilder<InsightsBloc, InsightsState>(
          builder: (context, state) => switch (state) {
            InsightsInitial() || InsightsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            InsightsError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<InsightsBloc>()
                          .add(const InsightsRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            InsightsLoaded(:final activeInsights, :final acknowledgedInsights)
                when activeInsights.isEmpty && acknowledgedInsights.isEmpty =>
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No insights yet'),
                  ],
                ),
              ),
            InsightsLoaded(:final activeInsights, :final acknowledgedInsights) =>
              RefreshIndicator(
                onRefresh: () async => context
                    .read<InsightsBloc>()
                    .add(const InsightsRequested()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (activeInsights.isNotEmpty) ...[
                      Text(
                        'Active',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...activeInsights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InsightCard(
                            insight: insight,
                            onAcknowledge: () => context
                                .read<InsightsBloc>()
                                .add(InsightAcknowledged(insight.id)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (acknowledgedInsights.isNotEmpty) ...[
                      Text(
                        'Acknowledged',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...acknowledgedInsights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InsightCard(insight: insight),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}
