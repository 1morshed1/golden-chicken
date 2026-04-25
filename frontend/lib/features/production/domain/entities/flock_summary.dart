import 'package:equatable/equatable.dart';

class FlockSummary extends Equatable {
  const FlockSummary({
    required this.totalBirds,
    required this.alertCount,
    required this.avgAgeDays,
    required this.aiScore,
    required this.alerts,
    required this.feedPlan,
    this.lastUpdated,
  });

  final int totalBirds;
  final int alertCount;
  final int avgAgeDays;
  final int aiScore;
  final List<FarmAlert> alerts;
  final List<FeedPlanItem> feedPlan;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props =>
      [totalBirds, alertCount, avgAgeDays, aiScore, alerts, feedPlan];
}

class FarmAlert extends Equatable {
  const FarmAlert({
    required this.id,
    required this.title,
    required this.type,
    this.description,
  });

  final String id;
  final String title;
  final String type;
  final String? description;

  @override
  List<Object?> get props => [id, title, type];
}

class FeedPlanItem extends Equatable {
  const FeedPlanItem({
    required this.name,
    required this.amountKg,
  });

  final String name;
  final double amountKg;

  @override
  List<Object?> get props => [name, amountKg];
}
