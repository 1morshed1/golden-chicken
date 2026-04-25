import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/complete_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/create_task.dart';
import 'package:golden_chicken/features/tasks/domain/usecases/get_tasks.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_event.dart';
import 'package:golden_chicken/features/tasks/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required GetTasks getTasks,
    required CreateTask createTask,
    required CompleteTask completeTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _completeTask = completeTask,
        super(const TaskInitial()) {
    on<TasksRequested>(_onTasksRequested);
    on<TaskCompleted>(_onTaskCompleted);
    on<TaskCreated>(_onTaskCreated);
  }

  final GetTasks _getTasks;
  final CreateTask _createTask;
  final CompleteTask _completeTask;

  Future<void> _onTasksRequested(
    TasksRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await _getTasks();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks: tasks)),
    );
  }

  Future<void> _onTaskCompleted(
    TaskCompleted event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _completeTask(event.taskId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => add(const TasksRequested()),
    );
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskSaving());
    final result = await _createTask(
      title: event.title,
      type: event.type,
      dueDate: event.dueDate,
      dueTime: event.dueTime,
      recurrence: event.recurrence,
      description: event.description,
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {
        emit(const TaskSaved());
        add(const TasksRequested());
      },
    );
  }
}
