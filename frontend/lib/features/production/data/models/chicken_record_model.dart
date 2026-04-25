import 'package:golden_chicken/features/production/domain/entities/chicken_record.dart';

class ChickenRecordModel extends ChickenRecord {
  const ChickenRecordModel({
    required super.id,
    required super.shedId,
    required super.date,
    required super.mortality,
    super.culled,
    super.sold,
    super.notes,
  });

  factory ChickenRecordModel.fromJson(Map<String, dynamic> json) {
    return ChickenRecordModel(
      id: json['id'] as String,
      shedId: json['shed_id'] as String,
      date: DateTime.parse(json['date'] as String),
      mortality: (json['mortality'] as num).toInt(),
      culled: (json['culled'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'shed_id': shedId,
        'date': date.toIso8601String().split('T').first,
        'mortality': mortality,
        'culled': culled,
        'sold': sold,
        if (notes != null) 'notes': notes,
      };
}
