import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';

class GetSheds {
  const GetSheds(this._repository);

  final ProductionRepository _repository;

  Future<Either<Failure, List<Shed>>> call() => _repository.getSheds();
}
