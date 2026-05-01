import 'package:golden_chicken/features/production/domain/entities/shed.dart';

class ShedModel extends Shed {
  const ShedModel({required super.id, required super.name});

  factory ShedModel.fromJson(Map<String, dynamic> json) {
    return ShedModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
