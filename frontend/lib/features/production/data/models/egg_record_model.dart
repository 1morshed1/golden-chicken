import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';

class EggRecordModel extends EggRecord {
  const EggRecordModel({
    required super.id,
    required super.shedId,
    required super.date,
    required super.totalEggs,
    super.brokenEggs,
    super.soldEggs,
    super.notes,
  });

  factory EggRecordModel.fromJson(Map<String, dynamic> json) {
    return EggRecordModel(
      id: json['id'] as String,
      shedId: json['shed_id'] as String,
      date: DateTime.parse(json['record_date'] as String),
      totalEggs: (json['total_eggs'] as num).toInt(),
      brokenEggs: (json['broken_eggs'] as num?)?.toInt() ?? 0,
      soldEggs: (json['sold_eggs'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'record_date': date.toIso8601String().split('T').first,
        'total_eggs': totalEggs,
        'broken_eggs': brokenEggs,
        'sold_eggs': soldEggs,
        if (notes != null) 'notes': notes,
      };
}
