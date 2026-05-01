import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_chicken_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/add_egg_record.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_flock_overview.dart';
import 'package:golden_chicken/features/production/domain/usecases/get_sheds.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_bloc.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_event.dart';
import 'package:golden_chicken/features/production/presentation/bloc/production_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFlockOverview extends Mock implements GetFlockOverview {}

class MockAddEggRecord extends Mock implements AddEggRecord {}

class MockAddChickenRecord extends Mock implements AddChickenRecord {}

class MockGetSheds extends Mock implements GetSheds {}

void main() {
  late ProductionBloc bloc;
  late MockGetFlockOverview mockGetFlockOverview;
  late MockAddEggRecord mockAddEggRecord;
  late MockAddChickenRecord mockAddChickenRecord;
  late MockGetSheds mockGetSheds;

  final testSummary = FlockSummary(
    totalBirds: 500,
    alertCount: 2,
    avgAgeDays: 45,
    aiScore: 85,
    alerts: const [],
    feedPlan: const [],
    lastUpdated: DateTime(2026),
  );

  const testSheds = [
    Shed(id: 'shed-1', name: 'Shed A'),
    Shed(id: 'shed-2', name: 'Shed B'),
  ];

  setUp(() {
    mockGetFlockOverview = MockGetFlockOverview();
    mockAddEggRecord = MockAddEggRecord();
    mockAddChickenRecord = MockAddChickenRecord();
    mockGetSheds = MockGetSheds();
    bloc = ProductionBloc(
      getFlockOverview: mockGetFlockOverview,
      addEggRecord: mockAddEggRecord,
      addChickenRecord: mockAddChickenRecord,
      getSheds: mockGetSheds,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is ProductionInitial', () {
    expect(bloc.state, const ProductionInitial());
  });

  group('ShedsRequested', () {
    blocTest<ProductionBloc, ProductionState>(
      'emits [ProductionLoading, ShedsLoaded] on success',
      build: () {
        when(() => mockGetSheds()).thenAnswer(
          (_) async => const Right(testSheds),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ShedsRequested()),
      expect: () => [
        const ProductionLoading(),
        const ShedsLoaded(testSheds),
      ],
    );

    blocTest<ProductionBloc, ProductionState>(
      'emits [ProductionLoading, ProductionError] on failure',
      build: () {
        when(() => mockGetSheds()).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ShedsRequested()),
      expect: () => [
        const ProductionLoading(),
        isA<ProductionError>(),
      ],
    );
  });

  group('FlockOverviewRequested', () {
    blocTest<ProductionBloc, ProductionState>(
      'emits [ProductionLoading, ProductionLoaded] on success',
      build: () {
        when(() => mockGetFlockOverview()).thenAnswer(
          (_) async => Right(testSummary),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const FlockOverviewRequested()),
      expect: () => [
        const ProductionLoading(),
        ProductionLoaded(summary: testSummary),
      ],
    );
  });

  group('EggRecordAdded', () {
    blocTest<ProductionBloc, ProductionState>(
      'emits [RecordSaving, RecordSaved, ...] on success',
      build: () {
        when(
          () => mockAddEggRecord(
            shedId: any(named: 'shedId'),
            date: any(named: 'date'),
            totalEggs: any(named: 'totalEggs'),
            brokenEggs: any(named: 'brokenEggs'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer(
          (_) async => Right(
            EggRecord(
              id: '1',
              shedId: 'shed-1',
              date: DateTime(2026),
              totalEggs: 100,
            ),
          ),
        );
        when(() => mockGetFlockOverview()).thenAnswer(
          (_) async => Right(testSummary),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        EggRecordAdded(
          shedId: 'shed-1',
          date: DateTime(2026),
          totalEggs: 100,
        ),
      ),
      expect: () => [
        const RecordSaving(),
        const RecordSaved(),
        const ProductionLoading(),
        ProductionLoaded(summary: testSummary),
      ],
    );
  });
}
