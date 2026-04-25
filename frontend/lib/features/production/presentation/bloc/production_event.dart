import 'package:equatable/equatable.dart';

sealed class ProductionEvent extends Equatable {
  const ProductionEvent();

  @override
  List<Object?> get props => [];
}

final class FlockOverviewRequested extends ProductionEvent {
  const FlockOverviewRequested();
}

final class EggRecordAdded extends ProductionEvent {
  const EggRecordAdded({
    required this.shedId,
    required this.date,
    required this.totalEggs,
    this.brokenEggs = 0,
    this.notes,
  });

  final String shedId;
  final DateTime date;
  final int totalEggs;
  final int brokenEggs;
  final String? notes;

  @override
  List<Object?> get props => [shedId, date, totalEggs, brokenEggs];
}

final class ChickenRecordAdded extends ProductionEvent {
  const ChickenRecordAdded({
    required this.shedId,
    required this.date,
    required this.mortality,
    this.culled = 0,
    this.sold = 0,
    this.notes,
  });

  final String shedId;
  final DateTime date;
  final int mortality;
  final int culled;
  final int sold;
  final String? notes;

  @override
  List<Object?> get props => [shedId, date, mortality, culled, sold];
}
