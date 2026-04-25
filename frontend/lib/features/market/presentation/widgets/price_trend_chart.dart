import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';

class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({
    required this.eggTrend,
    required this.meatTrend,
    super.key,
  });

  final List<PriceTrendPoint> eggTrend;
  final List<PriceTrendPoint> meatTrend;

  @override
  Widget build(BuildContext context) {
    if (eggTrend.isEmpty && meatTrend.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No trend data')),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        children: [
          const Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Egg'),
              SizedBox(width: AppSpacing.lg),
              _LegendDot(color: AppColors.info, label: 'Meat'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  horizontalInterval: 50,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        '৳${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  if (eggTrend.isNotEmpty)
                    _buildLine(eggTrend, AppColors.primary),
                  if (meatTrend.isNotEmpty)
                    _buildLine(meatTrend, AppColors.info),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.secondary,
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            '৳${spot.y.toStringAsFixed(1)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<PriceTrendPoint> points, Color color) {
    return LineChartBarData(
      spots: List.generate(
        points.length,
        (i) => FlSpot(i.toDouble(), points[i].price),
      ),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withAlpha(26),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
