import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';

class FarmAlertModel extends FarmAlert {
  const FarmAlertModel({
    required super.id,
    required super.title,
    required super.type,
    super.description,
  });

  factory FarmAlertModel.fromJson(Map<String, dynamic> json) {
    return FarmAlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: (json['type'] as String?) ?? 'info',
      description: json['description'] as String?,
    );
  }
}

class FeedPlanItemModel extends FeedPlanItem {
  const FeedPlanItemModel({
    required super.name,
    required super.amountKg,
  });

  factory FeedPlanItemModel.fromJson(Map<String, dynamic> json) {
    return FeedPlanItemModel(
      name: json['name'] as String,
      amountKg: (json['amount_kg'] as num).toDouble(),
    );
  }
}

class FlockSummaryModel extends FlockSummary {
  const FlockSummaryModel({
    required super.totalBirds,
    required super.alertCount,
    required super.avgAgeDays,
    required super.aiScore,
    required super.alerts,
    required super.feedPlan,
    super.lastUpdated,
  });

  factory FlockSummaryModel.fromJson(Map<String, dynamic> json) {
    final alerts = (json['alerts'] as List<dynamic>?)
            ?.map((e) => FarmAlertModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final feedPlan = (json['feed_plan'] as List<dynamic>?)
            ?.map(
              (e) => FeedPlanItemModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return FlockSummaryModel(
      totalBirds: (json['total_birds'] as num).toInt(),
      alertCount: (json['alert_count'] as num?)?.toInt() ?? alerts.length,
      avgAgeDays: (json['avg_age_days'] as num).toInt(),
      aiScore: (json['ai_score'] as num).toInt(),
      alerts: alerts,
      feedPlan: feedPlan,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }
}
