import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/constant.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../core/widgets/custom_card.dart';
import 'insight_helpers.dart';

class CashFlowTab extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> dayLabels;

  const CashFlowTab({
    required this.incomeData,
    required this.expenseData,
    required this.dayLabels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool empty =
        incomeData.every((v) => v == 0) && expenseData.every((v) => v == 0);

    if (empty) {
      return _buildEmptyState();
    }

    final double totalIncome = incomeData.fold(0, (a, b) => a + b);
    final double totalExpense = expenseData.fold(0, (a, b) => a + b);
    final double maxVal = [...incomeData, ...expenseData].reduce(max);
    final double maxY = maxVal == 0 ? 100 : maxVal * 1.25;
    final double yInterval = (maxY / 4).clamp(1.0, double.infinity);
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
                    'Cash Flow Trend',
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
                      bottom: 12,
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
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          _buildLine(incomeData, Constant.limeAccent),
                          _buildLine(expenseData, Constant.expenseRed),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.blueGrey.shade800,
                            getTooltipItems: (spots) => spots.map((s) {
                              final label = s.barIndex == 0 ? 'Income' : 'Expense';
                              return LineTooltipItem(
                                '$label\n${Utils.formatIDR(s.y)}',
                                TextStyle(
                                  color: s.bar.color ?? Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Legend
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InsightLegendDot(color: Constant.limeAccent, label: 'Income'),
                      SizedBox(width: 20),
                      InsightLegendDot(color: Constant.expenseRed, label: 'Expense'),
                    ],
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
                  'Cash Flow Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Income
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Income',
                      style: TextStyle(
                        fontSize: 12,
                        color: Constant.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Utils.formatIDR(totalIncome),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Constant.limeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Constant.borderSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: totalIncome > 0
                          ? (totalIncome / (totalIncome + totalExpense)).clamp(0.0, 1.0)
                          : 0.0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Constant.limeAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Expense',
                      style: TextStyle(
                        fontSize: 12,
                        color: Constant.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Utils.formatIDR(totalExpense),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Constant.expenseRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Constant.borderSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: totalExpense > 0
                          ? (totalExpense / (totalIncome + totalExpense)).clamp(0.0, 1.0)
                          : 0.0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Constant.expenseRed,
                          borderRadius: BorderRadius.circular(6),
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
        'assets/icons/cow_mascot_empty.png',
        "Insight kosong",
        "Tidak ada transaksi di bulan ini",
        textColor: Constant.textSecondary,
      ),
    );
  }

  LineChartBarData _buildLine(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(
        dayLabels.length,
        (i) => FlSpot(i.toDouble(), data[i]),
      ),
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }
}