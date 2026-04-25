import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/insights/domain/repositories/insights_repository.dart';

class AcknowledgeInsight {
  const AcknowledgeInsight(this._repository);

  final InsightsRepository _repository;

  Future<Either<Failure, void>> call(String insightId) =>
      _repository.acknowledgeInsight(insightId);
}
