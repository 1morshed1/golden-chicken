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
    required this.items,
    this.selectedCategory,
    this.isAskingAi = false,
    this.askAiError,
  });

  final List<HealthItem> items;
  final String? selectedCategory;
  final bool isAskingAi;
  final String? askAiError;

  List<HealthItem> get filteredItems {
    if (selectedCategory == null) return items;
    return items.where((i) => i.category == selectedCategory).toList();
  }

  List<String> get categories {
    return items
        .map((i) => i.category)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  HealthLoaded copyWith({
    List<HealthItem>? items,
    String? Function()? selectedCategory,
    bool? isAskingAi,
    String? Function()? askAiError,
  }) =>
      HealthLoaded(
        items: items ?? this.items,
        selectedCategory:
            selectedCategory != null ? selectedCategory() : this.selectedCategory,
        isAskingAi: isAskingAi ?? this.isAskingAi,
        askAiError: askAiError != null ? askAiError() : this.askAiError,
      );

  @override
  List<Object?> get props => [items, selectedCategory, isAskingAi, askAiError];
}

final class HealthError extends HealthState {
  const HealthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
