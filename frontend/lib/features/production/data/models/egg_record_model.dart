import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';

class EggRecordModel extends EggRecord {
  const EggRecordModel({
    required super.id,
    required super.shedId,
    required super.date,
    required super.totalEggs,
    super.brokenEggs,
    super.notes,
  });

  factory EggRecordModel.fromJson(Map<String, dynamic> json) {
    return EggRecordModel(
      id: json['id'] as String,
      shedId: json['shed_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalEggs: (json['total_eggs'] as num).toInt(),
      brokenEggs: (json['broken_eggs'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'shed_id': shedId,
        'date': date.toIso8601String().split('T').first,
        'total_eggs': totalEggs,
        'broken_eggs': brokenEggs,
        if (notes != null) 'notes': notes,
      };
}
