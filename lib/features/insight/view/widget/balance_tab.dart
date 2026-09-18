import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/constant.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../core/widgets/custom_card.dart';
import 'insight_helpers.dart';

class BalanceTab extends StatelessWidget {
  final List<double> balanceData;
  final List<String> dayLabels;

  const BalanceTab({
    required this.balanceData,
    required this.dayLabels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (balanceData.isEmpty) {
      return _buildEmptyState();
    }

    final double maxBalance = balanceData.reduce(max);
    final double minBalance = balanceData.reduce(min);
    final double range = (maxBalance - minBalance).abs();
    final double pad = range == 0 ? 100.0 : range * 0.15;
    final double maxY = maxBalance > 0 ? maxBalance + pad : 100.0;
    final double minY = minBalance < 0 ? minBalance - pad : 0.0;
    final double yInterval = ((maxY - minY) / 4).abs().clamp(
      1.0,
      double.infinity,
    );
    final int totalDays = dayLabels.length;
    final int xStep = (totalDays / 5).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Chart Card
          CustomCard.surface(
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Balance Trend',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Constant.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                      left: 8,
                      top: 16,
                      bottom: 16,
                    ),
                    child: LineChart(
                      LineChartData(
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Constant.borderSubtle,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: buildInsightTitles(
                          dayLabels: dayLabels,
                          totalDays: totalDays,
                          xStep: xStep,
                          yInterval: yInterval,
                        ),
                        borderData: buildInsightBorderData(),
                        minX: 0,
                        maxX: (totalDays - 1).toDouble(),
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              dayLabels.length,
                              (i) => FlSpot(i.toDouble(), balanceData[i]),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.2,
                            preventCurveOverShooting: true,
                            color: Constant.incomeGreenAccentDark,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Constant.incomeGreenAccentDark.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: buildInsightTouchData(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Summary Card
          CustomCard.surface(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Utils.formatIDR(balanceData.last),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Constant.borderSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          ((balanceData.last - balanceData.reduce(min)) /
                                  (balanceData.reduce(max) -
                                      balanceData.reduce(min)))
                              .clamp(0.0, 1.0),
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Constant.incomeGreenAccentDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Constant.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Constant.borderSubtle),
      ),
      child: Utils.emptyState(
        Icon(
          LucideIcons.databaseX600,
          size: 100,
          color: Constant.limeAccentDark,
        ),
        "Insight kosong",
        "Tidak ada transaksi di bulan ini",
        textColor: Constant.textSecondary,
      ),
    );
  }
}
