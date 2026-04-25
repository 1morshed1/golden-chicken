import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';

abstract class InsightsRepository {
  Future<Either<Failure, List<FarmInsight>>> getInsights();
  Future<Either<Failure, void>> acknowledgeInsight(String insightId);
}
