import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/chicken_record.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';

class AddChickenRecord {
  const AddChickenRecord(this._repository);

  final ProductionRepository _repository;

  Future<Either<Failure, ChickenRecord>> call({
    required String shedId,
    required DateTime date,
    required int mortality,
    int culled = 0,
    int sold = 0,
    String? notes,
  }) =>
      _repository.addChickenRecord(
        shedId: shedId,
        date: date,
        mortality: mortality,
        culled: culled,
        sold: sold,
        notes: notes,
      );
}
