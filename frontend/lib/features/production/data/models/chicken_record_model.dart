import 'package:golden_chicken/features/production/domain/entities/chicken_record.dart';

class ChickenRecordModel extends ChickenRecord {
  const ChickenRecordModel({
    required super.id,
    required super.shedId,
    required super.date,
    required super.totalBirds,
    super.additions,
    super.mortality,
    super.notes,
  });

  factory ChickenRecordModel.fromJson(Map<String, dynamic> json) {
    return ChickenRecordModel(
      id: json['id'] as String,
      shedId: json['shed_id'] as String,
      date: DateTime.parse(json['record_date'] as String),
      totalBirds: (json['total_birds'] as num).toInt(),
      additions: (json['additions'] as num?)?.toInt() ?? 0,
      mortality: (json['mortality'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'record_date': date.toIso8601String().split('T').first,
        'total_birds': totalBirds,
        'additions': additions,
        'mortality': mortality,
        if (notes != null) 'notes': notes,
      };
}
