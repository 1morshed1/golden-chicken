import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_button.dart';
import 'package:golden_chicken/core/widgets/app_text_field.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_bloc.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_event.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_state.dart';
import 'package:golden_chicken/features/production/presentation/widgets/shed_picker.dart';

class EggRecordsScreen extends StatelessWidget {
  const EggRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProductionBloc>()..add(const ShedsRequested('default')),
      child: const _EggRecordForm(),
    );
  }
}

class _EggRecordForm extends StatefulWidget {
  const _EggRecordForm();

  @override
  State<_EggRecordForm> createState() => _EggRecordFormState();
}

class _EggRecordFormState extends State<_EggRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _brokenController = TextEditingController();
  final _soldController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedShedId;
  List<Shed> _sheds = [];

  @override
  void dispose() {
    _totalController.dispose();
    _brokenController.dispose();
    _soldController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eggRecords)),
      body: BlocListener<ProductionBloc, ProductionState>(
        listener: (context, state) {
          if (state is ShedsLoaded) {
            setState(() {
              _sheds = state.sheds;
              if (_sheds.length == 1) {
                _selectedShedId = _sheds.first.id;
              }
            });
          } else if (state is RecordSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Record saved')),
            );
            Navigator.of(context).pop();
          } else if (state is ProductionError) {
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
              ShedPicker(
                sheds: _sheds,
                selectedShedId: _selectedShedId,
                onChanged: (id) => setState(() => _selectedShedId = id),
              ),
              const SizedBox(height: AppSpacing.lg),
              _DateSelector(
                date: _selectedDate,
                onChanged: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _totalController,
                label: 'Total Eggs',
                hint: 'Enter total egg count',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _brokenController,
                label: 'Broken Eggs',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _soldController,
                label: 'Sold Eggs',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Optional notes',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<ProductionBloc, ProductionState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Save Record',
                    isLoading: state is RecordSaving,
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
    context.read<ProductionBloc>().add(
          EggRecordAdded(
            shedId: _selectedShedId!,
            date: _selectedDate,
            totalEggs: int.parse(_totalController.text),
            brokenEggs: int.tryParse(_brokenController.text) ?? 0,
            soldEggs: int.tryParse(_soldController.text) ?? 0,
            notes: _notesController.text.isEmpty
                ? null
                : _notesController.text,
          ),
        );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          suffixIcon: Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
