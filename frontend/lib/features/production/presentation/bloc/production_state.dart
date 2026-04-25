import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';

sealed class ProductionState extends Equatable {
  const ProductionState();

  @override
  List<Object?> get props => [];
}

final class ProductionInitial extends ProductionState {
  const ProductionInitial();
}

final class ProductionLoading extends ProductionState {
  const ProductionLoading();
}

final class ProductionLoaded extends ProductionState {
  const ProductionLoaded({required this.summary});

  final FlockSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class ProductionError extends ProductionState {
  const ProductionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class RecordSaving extends ProductionState {
  const RecordSaving();
}

final class RecordSaved extends ProductionState {
  const RecordSaved();
}
