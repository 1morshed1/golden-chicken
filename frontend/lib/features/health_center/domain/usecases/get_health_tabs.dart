import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';
import 'package:golden_chicken/features/health_center/domain/repositories/health_repository.dart';

class GetHealthTabs {
  const GetHealthTabs(this._repository);

  final HealthRepository _repository;

  Future<Either<Failure, List<HealthTab>>> call() => _repository.getHealthTabs();
}
