import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/constant.dart';
import '../../../../../core/utils/utils.dart';

FlTitlesData buildInsightTitles({
  required List<String> dayLabels,
  required int totalDays,
  required int xStep,
  required double yInterval,
}) {
  return FlTitlesData(
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= dayLabels.length) {
            return const SizedBox.shrink();
          }
          final int day = index + 1;
          final bool tooClose =
              day % xStep == 0 && (totalDays - day) < xStep ~/ 2;
          if (day == 1 || (day % xStep == 0 && !tooClose) || day == totalDays) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8,
              child: Text(
                dayLabels[index],
                style: const TextStyle(color: Constant.textSecondary, fontSize: 10),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: yInterval,
        reservedSize: 48,
        getTitlesWidget: (value, meta) {
          if (value == meta.max || value == meta.min) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              Utils.formatCompactNumber(value),
              style: const TextStyle(color: Constant.textSecondary, fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

FlBorderData buildInsightBorderData() => FlBorderData(
  show: true,
  border: const Border(
    bottom: BorderSide(color: Constant.borderSubtle, width: 1),
    left: BorderSide(color: Colors.transparent),
    right: BorderSide(color: Colors.transparent),
    top: BorderSide(color: Colors.transparent),
  ),
);

LineTouchData buildInsightTouchData() => LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (_) => Colors.blueGrey.shade800,
    getTooltipItems: (spots) => spots.map((s) {
      return LineTooltipItem(
        'Day ${s.x.toInt() + 1}\n${Utils.formatIDR(s.y)}',
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList(),
  ),
);

class InsightLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const InsightLegendDot({required this.color, required this.label, super.key});

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
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Constant.textSecondary),
        ),
      ],
    );
  }
}