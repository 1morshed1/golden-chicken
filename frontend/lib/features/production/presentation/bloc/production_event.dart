import 'package:equatable/equatable.dart';

sealed class ProductionEvent extends Equatable {
  const ProductionEvent();

  @override
  List<Object?> get props => [];
}

final class FlockOverviewRequested extends ProductionEvent {
  const FlockOverviewRequested();
}

final class ShedsRequested extends ProductionEvent {
  const ShedsRequested(this.farmId);

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}

final class EggRecordAdded extends ProductionEvent {
  const EggRecordAdded({
    required this.shedId,
    required this.date,
    required this.totalEggs,
    this.brokenEggs = 0,
    this.soldEggs = 0,
    this.notes,
  });

  final String shedId;
  final DateTime date;
  final int totalEggs;
  final int brokenEggs;
  final int soldEggs;
  final String? notes;

  @override
  List<Object?> get props => [shedId, date, totalEggs, brokenEggs];
}

final class ChickenRecordAdded extends ProductionEvent {
  const ChickenRecordAdded({
    required this.shedId,
    required this.date,
    required this.totalBirds,
    this.additions = 0,
    this.mortality = 0,
    this.notes,
  });

  final String shedId;
  final DateTime date;
  final int totalBirds;
  final int additions;
  final int mortality;
  final String? notes;

  @override
  List<Object?> get props => [shedId, date, totalBirds, mortality];
}
