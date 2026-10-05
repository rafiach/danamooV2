import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:danamoo/core/constants/constant.dart';
import 'package:danamoo/core/utils/utils.dart';
import 'package:danamoo/core/widgets/custom_card.dart';
import 'insight_helpers.dart';

class _Week {
  final int start; // tanggal awal (1-based)
  final int end; // tanggal akhir
  final double income;
  final double expense;

  const _Week({
    required this.start,
    required this.end,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
  String get range => start == end ? '$start' : '$start–$end';
}

class CashFlowTab extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> dayLabels;
  final int visibleDays; // hari yang sudah berjalan (bulan berjalan = hari ini)
  final List<DateTime> trendMonths;
  final List<double> trendIncome;
  final List<double> trendExpense;
  const CashFlowTab({
    required this.incomeData,
    required this.expenseData,
    required this.dayLabels,
    required this.visibleDays,
    required this.trendMonths,
    required this.trendIncome,
    required this.trendExpense,
    super.key,
  });

  // Bucket: 1–7, 8–14, 15–21, 22–28, 29–akhir. Minggu masa depan dibuang.
  List<_Week> _buildWeeks() {
    final total = dayLabels.length;
    final weeks = <_Week>[];
    for (int s = 0; s < total && s < visibleDays; s += 7) {
      final e = min(s + 7, total);
      double inc = 0;
      double exp = 0;
      for (int i = s; i < e; i++) {
        inc += incomeData[i];
        exp += expenseData[i];
      }
      weeks.add(_Week(start: s + 1, end: e, income: inc, expense: exp));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final bool empty =
        incomeData.every((v) => v == 0) && expenseData.every((v) => v == 0);
    if (empty) return _buildEmptyState();

    final weeks = _buildWeeks();
    final double maxVal = weeks
        .expand((w) => [w.income, w.expense])
        .reduce(max);
    final double maxY = maxVal == 0 ? 100 : maxVal * 1.25;
    final double yInterval = (maxY / 4).clamp(1.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildChartCard(weeks, maxY, yInterval),
          const SizedBox(height: 8),
          _buildWeeklyList(weeks),
          const SizedBox(height: 8),
          _buildTrendCard(),
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget _buildChartCard(List<_Week> weeks, double maxY, double yInterval) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Cash Flow Mingguan',
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
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Constant.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: buildInsightBorderData(),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= weeks.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              'M${i + 1}',
                              style: const TextStyle(
                                color: Constant.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
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
                              style: const TextStyle(
                                color: Constant.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(weeks.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: weeks[i].income,
                          color: Constant.incomeGreenAccentDark,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: weeks[i].expense,
                          color: Constant.expenseRed,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final w = weeks[groupIndex];
                        final label = rodIndex == 0 ? 'Income' : 'Expense';
                        return BarTooltipItem(
                          'Tgl ${w.range}\n$label\n${Utils.formatIDR(rod.toY)}',
                          TextStyle(
                            color: rod.color ?? Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InsightLegendDot(
                  color: Constant.incomeGreenAccentDark,
                  label: 'Income',
                ),
                SizedBox(width: 20),
                InsightLegendDot(color: Constant.expenseRed, label: 'Expense'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DAFTAR PER MINGGU =================
  Widget _buildWeeklyList(List<_Week> weeks) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian per Minggu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Constant.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < weeks.length; i++) ...[
            _WeekRow(index: i, week: weeks[i]),
            if (i != weeks.length - 1)
              const Divider(height: 1, color: Constant.borderSubtle),
          ],
        ],
      ),
    );
  }

  // ================= TREN 6 BULAN =================
  Widget _buildTrendCard() {
    final double maxVal = [...trendIncome, ...trendExpense].reduce(max);
    final double maxY = maxVal == 0 ? 100 : maxVal * 1.25;
    final double yInterval = (maxY / 4).clamp(1.0, double.infinity);
    final int last = trendMonths.length - 1;

    // Rata-rata hanya dari bulan yang punya data, supaya user baru tidak "turun"
    final active = [
      for (int i = 0; i <= last; i++)
        if (trendIncome[i] > 0 || trendExpense[i] > 0) i,
    ];
    final double avgExpense = active.isEmpty
        ? 0
        : active.fold<double>(0, (s, i) => s + trendExpense[i]) / active.length;

    // Bulan terpilih berwarna penuh, bulan lain dipudarkan
    Color shade(Color c, int i) => i == last ? c : c.withValues(alpha: 0.5);

    return CustomCard.surface(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Tren 6 Bulan',
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
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Constant.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: buildInsightBorderData(),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= trendMonths.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              DateFormat('MMM', 'id_ID').format(trendMonths[i]),
                              style: TextStyle(
                                color: i == last
                                    ? Constant.textPrimary
                                    : Constant.textSecondary,
                                fontWeight: i == last
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 10,
                              ),
                            ),
                          );
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
                              style: const TextStyle(
                                color: Constant.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(trendMonths.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: trendIncome[i],
                          color: shade(Constant.incomeGreenAccentDark, i),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: trendExpense[i],
                          color: shade(Constant.expenseRed, i),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = DateFormat(
                          'MMMM yyyy',
                          'id_ID',
                        ).format(trendMonths[groupIndex]);
                        final label = rodIndex == 0 ? 'Income' : 'Expense';
                        return BarTooltipItem(
                          '$month\n$label\n${Utils.formatIDR(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InsightLegendDot(
                color: Constant.incomeGreenAccentDark,
                label: 'Income',
              ),
              SizedBox(width: 20),
              InsightLegendDot(color: Constant.expenseRed, label: 'Expense'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rata-rata pengeluaran per bulan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Constant.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Utils.formatIDR(avgExpense),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
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

class _WeekRow extends StatelessWidget {
  final int index;
  final _Week week;

  const _WeekRow({required this.index, required this.week});

  @override
  Widget build(BuildContext context) {
    final net = week.net;
    final netColor = net == 0
        ? Constant.textSecondary
        : (net > 0 ? Constant.incomeGreenAccentDark : Constant.expenseRed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minggu ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Constant.textPrimary,
                  ),
                ),
                Text(
                  'Tgl ${week.range}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Constant.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${net >= 0 ? '+' : '-'} ${Utils.formatIDR(net.abs())}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: netColor,
                ),
              ),
              Text(
                '↓ ${Utils.formatCompactNumber(week.income)}   ↑ ${Utils.formatCompactNumber(week.expense)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Constant.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
