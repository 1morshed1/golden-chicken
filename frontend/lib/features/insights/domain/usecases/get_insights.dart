import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';
import 'package:golden_chicken/features/insights/domain/repositories/insights_repository.dart';

class GetInsights {
  const GetInsights(this._repository);

  final InsightsRepository _repository;

  Future<Either<Failure, List<FarmInsight>>> call() =>
      _repository.getInsights();
}
