import 'package:equatable/equatable.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

final class HealthTabsRequested extends HealthEvent {
  const HealthTabsRequested();
}

final class HealthCategorySelected extends HealthEvent {
  const HealthCategorySelected(this.category);
  final String? category;

  @override
  List<Object?> get props => [category];
}

final class HealthAskAiRequested extends HealthEvent {
  const HealthAskAiRequested({required this.tabId});
  final String tabId;

  @override
  List<Object?> get props => [tabId];
}
