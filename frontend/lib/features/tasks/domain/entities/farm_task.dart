import 'package:equatable/equatable.dart';

enum TaskType { feeding, cleaning, vaccination, inspection, other }

enum TaskStatus { pending, completed, overdue }

enum Recurrence { none, daily, weekly, custom }

class FarmTask extends Equatable {
  const FarmTask({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.dueDate,
    this.dueTime,
    this.recurrence = Recurrence.none,
    this.description,
    this.completedAt,
  });

  final String id;
  final String title;
  final TaskType type;
  final TaskStatus status;
  final DateTime dueDate;
  final String? dueTime;
  final Recurrence recurrence;
  final String? description;
  final DateTime? completedAt;

  bool get isOverdue =>
      status != TaskStatus.completed &&
      dueDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, title, type, status, dueDate, recurrence];
}
