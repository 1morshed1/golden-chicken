import 'package:flutter/material.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';

class ShedPicker extends StatelessWidget {
  const ShedPicker({
    required this.sheds,
    required this.selectedShedId,
    required this.onChanged,
    super.key,
  });

  final List<Shed> sheds;
  final String? selectedShedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedShedId,
      decoration: const InputDecoration(
        labelText: 'Shed',
        suffixIcon: Icon(Icons.warehouse_outlined, size: 20),
      ),
      hint: const Text('Select shed'),
      items: sheds
          .map(
            (shed) => DropdownMenuItem(
              value: shed.id,
              child: Text(shed.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a shed';
        return null;
      },
    );
  }
}
