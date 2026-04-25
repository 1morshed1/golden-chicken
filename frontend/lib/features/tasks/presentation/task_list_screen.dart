import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_error_widget.dart';
import 'package:golden_chicken/core/widgets/app_loading.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_event.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_state.dart';
import 'package:golden_chicken/features/tasks/presentation/widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(const TasksRequested()),
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskList)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/tasks/create'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) => switch (state) {
          TaskInitial() || TaskLoading() => const AppLoading(),
          TaskSaving() => const AppLoading(),
          TaskSaved() => const AppLoading(),
          TaskError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () =>
                  context.read<TaskBloc>().add(const TasksRequested()),
            ),
          TasksLoaded() => _TaskListBody(state: state),
        },
      ),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.state});

  final TasksLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'All caught up! No pending tasks.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(const TasksRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (state.overdue.isNotEmpty) ...[
            _SectionHeader(
              title: 'Overdue',
              count: state.overdue.length,
              color: AppColors.error,
            ),
            ...state.overdue.map(
              (task) => TaskCard(
                task: task,
                onComplete: () =>
                    context.read<TaskBloc>().add(TaskCompleted(task.id)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (state.today.isNotEmpty) ...[
            _SectionHeader(
              title: 'Today',
              count: state.today.length,
            ),
            ...state.today.map(
              (task) => TaskCard(
                task: task,
                onComplete: () =>
                    context.read<TaskBloc>().add(TaskCompleted(task.id)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (state.upcoming.isNotEmpty) ...[
            _SectionHeader(
              title: 'Upcoming',
              count: state.upcoming.length,
            ),
            ...state.upcoming.map(
              (task) => TaskCard(
                task: task,
                onComplete: () =>
                    context.read<TaskBloc>().add(TaskCompleted(task.id)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (state.completed.isNotEmpty) ...[
            _SectionHeader(
              title: 'Completed',
              count: state.completed.length,
              color: AppColors.success,
            ),
            ...state.completed.map(
              (task) => TaskCard(
                task: task,
                onComplete: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.color,
  });

  final String title;
  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: (color ?? AppColors.textSecondary).withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
