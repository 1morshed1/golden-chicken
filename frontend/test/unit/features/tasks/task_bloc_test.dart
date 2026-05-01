import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/complete_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/create_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/get_tasks.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_event.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTasks extends Mock implements GetTasks {}

class MockCreateTask extends Mock implements CreateTask {}

class MockCompleteTask extends Mock implements CompleteTask {}

void main() {
  setUpAll(() {
    registerFallbackValue(TaskType.feeding);
    registerFallbackValue(Recurrence.none);
    registerFallbackValue(DateTime(2026));
  });

  late TaskBloc bloc;
  late MockGetTasks mockGetTasks;
  late MockCreateTask mockCreateTask;
  late MockCompleteTask mockCompleteTask;

  final testTasks = [
    FarmTask(
      id: '1',
      title: 'Feed chickens',
      type: TaskType.feeding,
      status: TaskStatus.pending,
      dueDate: DateTime(2026, 5, 2),
    ),
    FarmTask(
      id: '2',
      title: 'Clean shed',
      type: TaskType.cleaning,
      status: TaskStatus.completed,
      dueDate: DateTime(2026, 4, 30),
    ),
  ];

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockCreateTask = MockCreateTask();
    mockCompleteTask = MockCompleteTask();
    bloc = TaskBloc(
      getTasks: mockGetTasks,
      createTask: mockCreateTask,
      completeTask: mockCompleteTask,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is TaskInitial', () {
    expect(bloc.state, const TaskInitial());
  });

  group('TasksRequested', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] on success',
      build: () {
        when(() => mockGetTasks()).thenAnswer(
          (_) async => Right(testTasks),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const TasksRequested()),
      expect: () => [
        const TaskLoading(),
        TasksLoaded(tasks: testTasks),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] on failure',
      build: () {
        when(() => mockGetTasks()).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const TasksRequested()),
      expect: () => [
        const TaskLoading(),
        isA<TaskError>(),
      ],
    );
  });

  group('TaskCompleted', () {
    blocTest<TaskBloc, TaskState>(
      'completes task then refreshes list',
      build: () {
        when(() => mockCompleteTask('1')).thenAnswer(
          (_) async => Right(testTasks.first),
        );
        when(() => mockGetTasks()).thenAnswer(
          (_) async => Right(testTasks),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const TaskCompleted('1')),
      expect: () => [
        const TaskLoading(),
        TasksLoaded(tasks: testTasks),
      ],
    );
  });

  group('TaskCreated', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskSaving, TaskSaved, ...] on success',
      build: () {
        when(
          () => mockCreateTask(
            title: any(named: 'title'),
            type: any(named: 'type'),
            dueDate: any(named: 'dueDate'),
            dueTime: any(named: 'dueTime'),
            recurrence: any(named: 'recurrence'),
            description: any(named: 'description'),
          ),
        ).thenAnswer((_) async => Right(testTasks.first));
        when(() => mockGetTasks()).thenAnswer(
          (_) async => Right(testTasks),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        TaskCreated(
          title: 'Feed chickens',
          type: TaskType.feeding,
          dueDate: DateTime(2026, 5, 2),
        ),
      ),
      expect: () => [
        const TaskSaving(),
        const TaskSaved(),
        const TaskLoading(),
        TasksLoaded(tasks: testTasks),
      ],
    );
  });
}
