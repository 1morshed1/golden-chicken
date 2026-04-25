import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

abstract class HealthRepository {
  Future<Either<Failure, List<HealthTab>>> getHealthTabs();

  Future<Either<Failure, String>> askHealthQuestion({
    required String tabId,
    required String question,
  });
}
