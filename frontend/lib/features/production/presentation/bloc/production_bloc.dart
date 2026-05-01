import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_chicken_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_egg_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_flock_overview.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_sheds.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_event.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_state.dart';

class ProductionBloc extends Bloc<ProductionEvent, ProductionState> {
  ProductionBloc({
    required GetFlockOverview getFlockOverview,
    required AddEggRecord addEggRecord,
    required AddChickenRecord addChickenRecord,
    required GetSheds getSheds,
  })  : _getFlockOverview = getFlockOverview,
        _addEggRecord = addEggRecord,
        _addChickenRecord = addChickenRecord,
        _getSheds = getSheds,
        super(const ProductionInitial()) {
    on<FlockOverviewRequested>(_onFlockOverviewRequested);
    on<ShedsRequested>(_onShedsRequested);
    on<EggRecordAdded>(_onEggRecordAdded);
    on<ChickenRecordAdded>(_onChickenRecordAdded);
  }

  final GetFlockOverview _getFlockOverview;
  final AddEggRecord _addEggRecord;
  final AddChickenRecord _addChickenRecord;
  final GetSheds _getSheds;

  Future<void> _onFlockOverviewRequested(
    FlockOverviewRequested event,
    Emitter<ProductionState> emit,
  ) async {
    emit(const ProductionLoading());
    final result = await _getFlockOverview();
    result.fold(
      (failure) => emit(ProductionError(failure.message)),
      (summary) => emit(ProductionLoaded(summary: summary)),
    );
  }

  Future<void> _onShedsRequested(
    ShedsRequested event,
    Emitter<ProductionState> emit,
  ) async {
    emit(const ProductionLoading());
    final result = await _getSheds();
    result.fold(
      (failure) => emit(ProductionError(failure.message)),
      (sheds) => emit(ShedsLoaded(sheds)),
    );
  }

  Future<void> _onEggRecordAdded(
    EggRecordAdded event,
    Emitter<ProductionState> emit,
  ) async {
    emit(const RecordSaving());
    final result = await _addEggRecord(
      shedId: event.shedId,
      date: event.date,
      totalEggs: event.totalEggs,
      brokenEggs: event.brokenEggs,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(ProductionError(failure.message)),
      (_) {
        emit(const RecordSaved());
        add(const FlockOverviewRequested());
      },
    );
  }

  Future<void> _onChickenRecordAdded(
    ChickenRecordAdded event,
    Emitter<ProductionState> emit,
  ) async {
    emit(const RecordSaving());
    final result = await _addChickenRecord(
      shedId: event.shedId,
      date: event.date,
      mortality: event.mortality,
      culled: event.culled,
      sold: event.sold,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(ProductionError(failure.message)),
      (_) {
        emit(const RecordSaved());
        add(const FlockOverviewRequested());
      },
    );
  }
}
