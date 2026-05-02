import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/health_center/domain/repositories/health_repository.dart';

class AskHealthQuestion {
  const AskHealthQuestion(this._repository);

  final HealthRepository _repository;

  Future<Either<Failure, String>> call({
    required String tabId,
    required String language,
  }) =>
      _repository.askHealthQuestion(tabId: tabId, language: language);
}
