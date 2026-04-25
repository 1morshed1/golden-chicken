import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';

class PriceHeroCard extends StatelessWidget {
  const PriceHeroCard({required this.price, super.key});

  final MarketPrice price;

  @override
  Widget build(BuildContext context) {
    final changeColor =
        price.isPositive ? AppColors.success : AppColors.error;
    final changeIcon =
        price.isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final sign = price.isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price.product,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '৳${price.price}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '/${price.unit}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(changeIcon, size: 14, color: changeColor),
              const SizedBox(width: 2),
              Text(
                '$sign${price.changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
