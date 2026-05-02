import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_bloc.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_event.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_state.dart';
import 'package:golden_chicken/features/health_center/presentation/widgets/disease_card.dart';

class HealthTabScreen extends StatelessWidget {
  const HealthTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) => sl<HealthBloc>()
        ..language = lang
        ..add(const HealthTabsRequested()),
      child: const _HealthTabView(),
    );
  }
}

class _HealthTabView extends StatelessWidget {
  const _HealthTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HealthBloc, HealthState>(
        listener: (context, state) {
          if (state is HealthLoaded) {
            if (state.askAiError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.askAiError!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            final bloc = context.read<HealthBloc>();
            final sessionId = bloc.consumeAskAiSessionId();
            if (sessionId != null) {
              context.push('/chat/detail?sessionId=$sessionId');
            }
          }
        },
        builder: (context, state) => switch (state) {
          HealthInitial() || HealthLoading() => const AppLoading(),
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
    final l10n = context.l10n;
    final items = state.filteredItems;

    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Text(
                  l10n.healthCenter,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryFilter(
                categories: state.categories,
                selected: state.selectedCategory,
                onSelected: (cat) => context
                    .read<HealthBloc>()
                    .add(HealthCategorySelected(cat)),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noData,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return DiseaseCard(
                            item: item,
                            onAskAi: () => context.read<HealthBloc>().add(
                                  HealthAskAiRequested(tabId: item.id),
                                ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        if (state.isAskingAi)
          const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Starting AI conversation...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final allLabel = locale == 'bn' ? 'রোগ' : 'Diseases';

    final tabs = [
      (null, allLabel),
      ...categories.map((c) => (c as String?, _categoryLabel(c, locale))),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xl),
        itemBuilder: (context, index) {
          final (cat, label) = tabs[index];
          final isSelected =
              (cat == null && selected == null) || cat == selected;

          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 2.5,
                  width: 28,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _categoryLabel(String category, String locale) {
    if (locale == 'bn') {
      return switch (category) {
        'viral' => 'ভাইরাল',
        'parasitic' => 'পরজীবী',
        'bacterial' => 'ব্যাকটেরিয়া',
        _ => category,
      };
    }
    return switch (category) {
      'viral' => 'Viral',
      'parasitic' => 'Parasitic',
      'bacterial' => 'Bacterial',
      _ => category,
    };
  }
}
