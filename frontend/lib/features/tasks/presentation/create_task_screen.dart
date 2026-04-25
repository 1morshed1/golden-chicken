import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/widgets/app_button.dart';
import 'package:golden_chicken/core/widgets/app_text_field.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_event.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_state.dart';
import 'package:golden_chicken/features/tasks/presentation/widgets/task_type_selector.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>(),
      child: const _CreateTaskForm(),
    );
  }
}

class _CreateTaskForm extends StatefulWidget {
  const _CreateTaskForm();

  @override
  State<_CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<_CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskType _type = TaskType.feeding;
  Recurrence _recurrence = Recurrence.none;
  DateTime _dueDate = DateTime.now();
  TimeOfDay? _dueTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task created')),
            );
            Navigator.of(context).pop();
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'e.g. Feed morning batch',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TaskTypeSelector(
                selected: _type,
                onSelected: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      date: _dueDate,
                      onChanged: (d) => setState(() => _dueDate = d),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TimeField(
                      time: _dueTime,
                      onChanged: (t) => setState(() => _dueTime = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Recurrence',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: Recurrence.values.map((r) {
                  final isSelected = r == _recurrence;
                  return ChoiceChip(
                    label: Text(_recurrenceLabel(r)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.border),
                    onSelected: (_) =>
                        setState(() => _recurrence = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _descriptionController,
                label: 'Notes',
                hint: 'Optional description',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Create Task',
                    isLoading: state is TaskSaving,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final timeStr = _dueTime != null
        ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
        : null;
    context.read<TaskBloc>().add(
          TaskCreated(
            title: _titleController.text.trim(),
            type: _type,
            dueDate: _dueDate,
            dueTime: timeStr,
            recurrence: _recurrence,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
          ),
        );
  }

  String _recurrenceLabel(Recurrence r) => switch (r) {
        Recurrence.none => 'None',
        Recurrence.daily => 'Daily',
        Recurrence.weekly => 'Weekly',
        Recurrence.custom => 'Custom',
      };
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          suffixIcon: Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.time, required this.onChanged});

  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time (optional)',
          suffixIcon: Icon(Icons.access_time, size: 20),
        ),
        child: Text(
          time != null ? time!.format(context) : '—',
        ),
      ),
    );
  }
}
