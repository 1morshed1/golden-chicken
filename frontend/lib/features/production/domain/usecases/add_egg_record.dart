import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';

class AddEggRecord {
  const AddEggRecord(this._repository);

  final ProductionRepository _repository;

  Future<Either<Failure, EggRecord>> call({
    required String shedId,
    required DateTime date,
    required int totalEggs,
    int brokenEggs = 0,
    String? notes,
  }) =>
      _repository.addEggRecord(
        shedId: shedId,
        date: date,
        totalEggs: totalEggs,
        brokenEggs: brokenEggs,
        notes: notes,
      );
}
