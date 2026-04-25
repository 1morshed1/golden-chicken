import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

sealed class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

final class HealthInitial extends HealthState {
  const HealthInitial();
}

final class HealthLoading extends HealthState {
  const HealthLoading();
}

final class HealthLoaded extends HealthState {
  const HealthLoaded({
    required this.tabs,
    required this.selectedType,
    this.searchQuery = '',
  });

  final List<HealthTab> tabs;
  final HealthTabType selectedType;
  final String searchQuery;

  List<HealthItem> get filteredItems {
    final tab = tabs.where((t) => t.type == selectedType).firstOrNull;
    if (tab == null) return [];
    if (searchQuery.isEmpty) return tab.items;
    final q = searchQuery.toLowerCase();
    return tab.items
        .where(
          (item) =>
              item.name.toLowerCase().contains(q) ||
              item.nameBn.contains(q),
        )
        .toList();
  }

  HealthLoaded copyWith({
    List<HealthTab>? tabs,
    HealthTabType? selectedType,
    String? searchQuery,
  }) =>
      HealthLoaded(
        tabs: tabs ?? this.tabs,
        selectedType: selectedType ?? this.selectedType,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [tabs, selectedType, searchQuery];
}

final class HealthError extends HealthState {
  const HealthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class HealthAskAiLoading extends HealthState {
  const HealthAskAiLoading();
}
