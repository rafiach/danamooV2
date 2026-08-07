import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../generated/assets.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/insight_provider.dart';

class InsightView extends StatefulWidget {
  const InsightView({super.key});

  @override
  State<InsightView> createState() => _InsightViewState();
}

class _InsightViewState extends State<InsightView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<InsightProvider>().fetchMonthlyData(user);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.violetDarker,
      appBar: CustomAppBar.standard(
        title: 'Insight',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Constant.violetDarker,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InsightProvider>(
        builder: (context, provider, child) {
          final model = provider.insightModel;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // ── Month Selector ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Constant.violet200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Constant.violetDarker,
                        ),
                        onPressed: () {
                          final user = context.read<AuthProvider>().user;
                          if (user != null) {
                            provider.changeMonth(
                              DateTime(
                                provider.selectedMonth.year,
                                provider.selectedMonth.month - 1,
                                1,
                              ),
                              user,
                            );
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Constant.violetDarker,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                                'id_ID',
                              ).format(provider.selectedMonth),
                              style: const TextStyle(
                                color: Constant.violetDarker,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Constant.violetDarker,
                        ),
                        onPressed: () {
                          final user = context.read<AuthProvider>().user;
                          if (user != null) {
                            provider.changeMonth(
                              DateTime(
                                provider.selectedMonth.year,
                                provider.selectedMonth.month + 1,
                                1,
                              ),
                              user,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tab Bar ─────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Constant.violet200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Constant.expensePrime,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Constant.violetDarker,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(height: 36, text: 'Balance'),
                      Tab(height: 36, text: 'Cash Flow'),
                      Tab(height: 36, text: 'Spending'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Content ─────────────────────────────────────────────────
                Expanded(
                  child: provider.isLoading || model == null
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _BalanceTab(
                              balanceData: model.balanceData,
                              dayLabels: model.dayLabels,
                            ),
                            _CashFlowTab(
                              incomeData: model.incomeData,
                              expenseData: model.expenseData,
                              dayLabels: model.dayLabels,
                            ),
                            _SpendingTab(
                              spendingByCategory: model.spendingByCategory,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1 – BALANCE
// ═══════════════════════════════════════════════════════════════════════════

class _BalanceTab extends StatelessWidget {
  final List<double> balanceData;
  final List<String> dayLabels;

  const _BalanceTab({required this.balanceData, required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    if (balanceData.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Utils.emptyState(
          Assets.assetsIconsCowMascotEmpty,
          "Insight kosong nihh",
          "Tidak ada transaksi di bulan ini",
          textColor: Constant.violetDarker,
        ),
      );
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
    final double currentBalance = balanceData.last;
    // Rasio bar horizontal terhadap balance paling tinggi di bulan ini
    final double ratio = maxBalance > 0
        ? (currentBalance / maxBalance).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
                      color: Constant.violetDarker,
                    ),
                  ),
                ),
                Expanded(
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
                            color: Constant.greyLight,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: _buildTitles(
                          dayLabels: dayLabels,
                          totalDays: totalDays,
                          xStep: xStep,
                          yInterval: yInterval,
                        ),
                        borderData: _borderData(),
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
                            color: Constant.violetDarker,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Constant.violetDarker.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: _touchData(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Constant.space8,
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Constant.violetDarker,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Utils.formatIDR(currentBalance),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constant.violetDarker,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Constant.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Constant.expensePrime,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 2 – CASH FLOW
// ═══════════════════════════════════════════════════════════════════════════

class _CashFlowTab extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> dayLabels;

  const _CashFlowTab({
    required this.incomeData,
    required this.expenseData,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    final bool empty =
        incomeData.every((v) => v == 0) && expenseData.every((v) => v == 0);

    if (empty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Utils.emptyState(
          Assets.assetsIconsCowMascotEmpty,
          "Insight kosong nihh",
          "Tidak ada transaksi di bulan ini",
          textColor: Constant.violetDarker,
        ),
      );
    }

    final double totalIncome = incomeData.fold(0, (a, b) => a + b);
    final double totalExpense = expenseData.fold(0, (a, b) => a + b);
    final double maxVal = [...incomeData, ...expenseData].reduce(max);
    final double maxY = maxVal == 0 ? 100 : maxVal * 1.25;
    final double yInterval = (maxY / 4).clamp(1.0, double.infinity);
    final int totalDays = dayLabels.length;
    final int xStep = (totalDays / 5).ceil();

    final double maxTotal = max(totalIncome, totalExpense);
    final double incomeRatio = maxTotal > 0
        ? (totalIncome / maxTotal).clamp(0.0, 1.0)
        : 0.0;
    final double expenseRatio = maxTotal > 0
        ? (totalExpense / maxTotal).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
                      color: Constant.violetDarker,
                    ),
                  ),
                ),
                Expanded(
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
                            color: Constant.greyLight,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: _buildTitles(
                          dayLabels: dayLabels,
                          totalDays: totalDays,
                          xStep: xStep,
                          yInterval: yInterval,
                        ),
                        borderData: _borderData(),
                        minX: 0,
                        maxX: (totalDays - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          _buildLine(incomeData, Constant.violetDarker),
                          _buildLine(expenseData, Constant.expensePrime),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.blueGrey.shade800,
                            getTooltipItems: (spots) => spots.map((s) {
                              final label = s.barIndex == 0
                                  ? 'Income'
                                  : 'Expense';
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: Constant.violetDarker, label: 'Income'),
                      const SizedBox(width: 20),
                      _LegendDot(
                        color: Constant.expensePrime,
                        label: 'Expense',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),

          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cash Flow Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Constant.violetDarker,
                ),
              ),
              const SizedBox(height: 16),
              // ====== INCOME ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Income',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constant.greyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Utils.formatIDR(totalIncome),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Constant.violetDarker,
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
                      color: Constant.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: incomeRatio,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Constant.violetDarker,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ====== EXPENSE ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Expense',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constant.greyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Utils.formatIDR(totalExpense),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Constant.expensePrime,
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
                      color: Constant.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: expenseRatio,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Constant.expensePrime,
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

// ═══════════════════════════════════════════════════════════════════════════
// TAB 3 – SPENDING
// ═══════════════════════════════════════════════════════════════════════════

class _SpendingTab extends StatefulWidget {
  final Map<String, double> spendingByCategory;
  const _SpendingTab({required this.spendingByCategory});

  @override
  State<_SpendingTab> createState() => _SpendingTabState();
}

class _SpendingTabState extends State<_SpendingTab> {
  int _touchedIndex = -1;

  static const List<Color> _pieColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFC62828),
    Color(0xFF558B2F),
    Color(0xFF4527A0),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final double total = entries.fold(0, (sum, e) => sum + e.value);
    final bool empty = widget.spendingByCategory.isEmpty;

    if (empty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Utils.emptyState(
          Assets.assetsIconsCowMascotEmpty,
          "Insight kosong nihh",
          "Tidak ada transaksi di bulan ini",
          textColor: Constant.violetDarker,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Constant.violetDarker,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                  } else {
                                    _touchedIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  }
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 58,
                            sections: List.generate(entries.length, (i) {
                              final isTouched = i == _touchedIndex;
                              final color = _pieColors[i % _pieColors.length];
                              final pct = entries[i].value / total * 100;
                              return PieChartSectionData(
                                color: color,
                                value: entries[i].value,
                                title: isTouched
                                    ? '${pct.toStringAsFixed(1)}%'
                                    : '',
                                radius: isTouched ? 70 : 58,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }),
                          ),
                        ),
                        // Center label
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _touchedIndex >= 0
                                  ? entries[_touchedIndex].key
                                  : 'Total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _touchedIndex >= 0
                                  ? Utils.formatCompactNumber(
                                      entries[_touchedIndex].value,
                                    )
                                  : Utils.formatCompactNumber(total),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Constant.violetDarker,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          flex: 4,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final color = _pieColors[i % _pieColors.length];
              final pct = entries[i].value / total * 100;
              return Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entries[i].key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Constant.greyDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Utils.formatIDR(entries[i].value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Constant.violetDarker,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Constant.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════════════

FlTitlesData _buildTitles({
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
                style: const TextStyle(color: Constant.greyDark, fontSize: 10),
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
              style: const TextStyle(color: Constant.greyDark, fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

FlBorderData _borderData() => FlBorderData(
  show: true,
  border: const Border(
    bottom: BorderSide(color: Constant.greyLight, width: 1),
    left: BorderSide(color: Colors.transparent),
    right: BorderSide(color: Colors.transparent),
    top: BorderSide(color: Colors.transparent),
  ),
);

LineTouchData _touchData() => LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (_) => Colors.blueGrey.shade800,
    getTooltipItems: (spots) => spots.map((s) {
      return LineTooltipItem(
        'Day ${s.x.toInt() + 1}\n${Utils.formatIDR(s.y)}',
        TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList(),
  ),
);

// ─────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

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
          style: const TextStyle(fontSize: 12, color: Constant.greyDark),
        ),
      ],
    );
  }
}
