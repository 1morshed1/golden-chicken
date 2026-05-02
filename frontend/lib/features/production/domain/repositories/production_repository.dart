import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/chicken_record.dart';
import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';

abstract class ProductionRepository {
  Future<Either<Failure, List<Shed>>> getSheds(String farmId);

  Future<Either<Failure, FlockSummary>> getFlockOverview();

  Future<Either<Failure, List<EggRecord>>> getEggRecords(String shedId);

  Future<Either<Failure, EggRecord>> addEggRecord({
    required String shedId,
    required DateTime date,
    required int totalEggs,
    int brokenEggs = 0,
    int soldEggs = 0,
    String? notes,
  });

  Future<Either<Failure, List<ChickenRecord>>> getChickenRecords(
    String shedId,
  );

  Future<Either<Failure, ChickenRecord>> addChickenRecord({
    required String shedId,
    required DateTime date,
    required int totalBirds,
    int additions = 0,
    int mortality = 0,
    String? notes,
  });
}
