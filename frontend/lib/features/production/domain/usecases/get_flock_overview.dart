import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';

class GetFlockOverview {
  const GetFlockOverview(this._repository);

  final ProductionRepository _repository;

  Future<Either<Failure, FlockSummary>> call() =>
      _repository.getFlockOverview();
}
