import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

final class HealthTabsRequested extends HealthEvent {
  const HealthTabsRequested();
}

final class HealthTabSelected extends HealthEvent {
  const HealthTabSelected(this.type);
  final HealthTabType type;

  @override
  List<Object?> get props => [type];
}

final class HealthSearchChanged extends HealthEvent {
  const HealthSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class HealthAskAiRequested extends HealthEvent {
  const HealthAskAiRequested({required this.tabId, required this.itemName});
  final String tabId;
  final String itemName;

  @override
  List<Object?> get props => [tabId, itemName];
}
