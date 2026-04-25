import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_bloc.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_event.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_state.dart';
import 'package:golden_chicken/features/health_center/presentation/widgets/disease_card.dart';
import 'package:golden_chicken/features/health_center/presentation/widgets/health_tab_filter.dart';

class HealthTabScreen extends StatelessWidget {
  const HealthTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthBloc>()..add(const HealthTabsRequested()),
      child: const _HealthTabView(),
    );
  }
}

class _HealthTabView extends StatelessWidget {
  const _HealthTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthCenter)),
      body: BlocConsumer<HealthBloc, HealthState>(
        listener: (context, state) {
          if (state is HealthLoaded) {
            final bloc = context.read<HealthBloc>();
            final sessionId = bloc.consumeAskAiSessionId();
            if (sessionId != null) {
              context.push('/chat/detail?sessionId=$sessionId');
            }
          }
        },
        builder: (context, state) => switch (state) {
          HealthInitial() || HealthLoading() => const AppLoading(),
          HealthAskAiLoading() => const AppLoading(),
          HealthError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context
                  .read<HealthBloc>()
                  .add(const HealthTabsRequested()),
            ),
          HealthLoaded() => _LoadedBody(state: state),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final HealthLoaded state;

  @override
  Widget build(BuildContext context) {
    final items = state.filteredItems;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            onChanged: (q) =>
                context.read<HealthBloc>().add(HealthSearchChanged(q)),
            decoration: InputDecoration(
              hintText: 'Search diseases, vaccines...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        HealthTabFilter(
          selected: state.selectedType,
          onSelected: (type) =>
              context.read<HealthBloc>().add(HealthTabSelected(type)),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.noData,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final tabId = state.tabs
                        .firstWhere((t) => t.type == state.selectedType)
                        .id;
                    return DiseaseCard(
                      item: item,
                      onAskAi: () => context.read<HealthBloc>().add(
                            HealthAskAiRequested(
                              tabId: tabId,
                              itemName: item.name,
                            ),
                          ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
