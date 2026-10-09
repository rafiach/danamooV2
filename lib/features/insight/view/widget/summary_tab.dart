import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:danamoo/core/constants/constant.dart';
import 'package:danamoo/core/utils/utils.dart';
import 'package:danamoo/core/widgets/custom_card.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/features/insight/model/insight_model.dart';
import 'insight_helpers.dart';

class SummaryTab extends StatelessWidget {
  final InsightModel model;

  const SummaryTab({required this.model, super.key});

  static const _titleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Constant.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final double totalIncome = model.incomeData.fold(0, (a, b) => a + b);
    final double totalExpense = model.expenseData.fold(0, (a, b) => a + b);

    if (totalIncome == 0 && totalExpense == 0) return _buildEmptyState();

    final int totalDays = model.dayLabels.length;
    final int visibleDays = model.visibleDays;
    final bool partial = visibleDays < totalDays;

    final double avgPerDay = totalExpense / visibleDays;
    final double avgPerTx = model.expenseCount > 0
        ? totalExpense / model.expenseCount
        : 0;
    // Proyeksi hanya untuk bulan berjalan
    final double? projection = partial && totalExpense > 0
        ? avgPerDay * totalDays
        : null;

    String topCategory = '-';
    if (model.expenseByCategory.isNotEmpty) {
      final top = model.expenseByCategory.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      topCategory = CategoryModel.getById(top.key)?.name ?? 'Lainnya';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildNetCard(totalIncome, totalExpense),
          const SizedBox(height: 8),
          _buildCompareCard(totalIncome, totalExpense, partial),
          const SizedBox(height: 8),
          _buildQuickStatsCard(avgPerDay, avgPerTx, topCategory, projection),
          const SizedBox(height: 8),
          _buildBalanceCard(totalDays, visibleDays, partial),
        ],
      ),
    );
  }

  // ================= NET =================
  Widget _buildNetCard(double income, double expense) {
    final net = income - expense;
    final color = net >= 0
        ? Constant.incomeGreenAccentDark
        : Constant.expenseRed;
    return CustomCard.surface(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selisih Bulan Ini', style: _titleStyle),
          const SizedBox(height: 4),
          Text(
            '${net >= 0 ? '+' : '-'} ${Utils.formatIDR(net.abs())}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Pemasukan',
                  value: Utils.formatIDR(income),
                  color: Constant.incomeGreenAccentDark,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Pengeluaran',
                  value: Utils.formatIDR(expense),
                  color: Constant.expenseRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= COMPARE =================
  Widget _buildCompareCard(double income, double expense, bool partial) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            partial
                ? 'Dibanding Periode Sama Bulan Lalu'
                : 'Dibanding Bulan Lalu',
            style: _titleStyle,
          ),
          const SizedBox(height: 12),
          _CompareRow(
            label: 'Pengeluaran',
            current: expense,
            previous: model.prevExpense,
            upIsGood: false,
          ),
          const SizedBox(height: 12),
          _CompareRow(
            label: 'Pemasukan',
            current: income,
            previous: model.prevIncome,
            upIsGood: true,
          ),
        ],
      ),
    );
  }

  // ================= QUICK STATS =================
  Widget _buildQuickStatsCard(
    double avgPerDay,
    double avgPerTx,
    String topCategory,
    double? projection,
  ) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Angka Cepat', style: _titleStyle),
          const SizedBox(height: 12),
          _InfoRow(
            'Rata-rata pengeluaran per hari',
            Utils.formatIDR(avgPerDay),
          ),
          _InfoRow('Transaksi pengeluaran', '${model.expenseCount}'),
          _InfoRow('Rata-rata per transaksi', Utils.formatIDR(avgPerTx)),
          _InfoRow('Kategori terbesar', topCategory),
          if (projection != null)
            _InfoRow(
              'Proyeksi pengeluaran akhir bulan',
              Utils.formatIDR(projection),
            ),
        ],
      ),
    );
  }

  // ================= BALANCE CHART =================
  Widget _buildBalanceCard(int totalDays, int visibleDays, bool partial) {
    final visible = model.balanceData.take(visibleDays).toList();
    final double maxBalance = visible.reduce(max);
    final double minBalance = visible.reduce(min);
    final double range = (maxBalance - minBalance).abs();
    final double pad = range == 0 ? 100.0 : range * 0.15;
    final double maxY = maxBalance > 0 ? maxBalance + pad : 100.0;
    final double minY = minBalance < 0 ? minBalance - pad : 0.0;
    final double yInterval = ((maxY - minY) / 4).abs().clamp(
      1.0,
      double.infinity,
    );
    final int xStep = (totalDays / 5).ceil();

    final double closing = visible.last;
    final double change = closing - model.openingBalance;

    return CustomCard.surface(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text('Tren Saldo', style: _titleStyle),
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
                    dayLabels: model.dayLabels,
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
                      // Hanya sampai hari ini, sisa hari dibiarkan kosong
                      spots: List.generate(
                        visibleDays,
                        (i) => FlSpot(i.toDouble(), model.balanceData[i]),
                      ),
                      isCurved: true,
                      curveSmoothness: 0.2,
                      preventCurveOverShooting: true,
                      color: Constant.incomeGreenAccentDark,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: visibleDays == 1),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _InfoRow(
                  'Saldo awal bulan',
                  Utils.formatIDR(model.openingBalance),
                ),
                _InfoRow(
                  partial ? 'Saldo sekarang' : 'Saldo akhir bulan',
                  Utils.formatIDR(closing),
                ),
                _InfoRow(
                  'Perubahan',
                  '${change >= 0 ? '+' : '-'} ${Utils.formatIDR(change.abs())}',
                  valueColor: change >= 0
                      ? Constant.incomeGreenAccentDark
                      : Constant.expenseRed,
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

// ================= SUB WIDGETS =================

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Constant.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Constant.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Constant.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final double current;
  final double previous;
  final bool upIsGood; // pemasukan naik = bagus, pengeluaran naik = buruk

  const _CompareRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.upIsGood,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPrev = previous > 0;
    final double pct = hasPrev ? (current - previous) / previous * 100 : 0;
    final bool isFlat = pct.abs() < 0.05;
    final bool isUp = pct > 0;

    final Color color = !hasPrev || isFlat
        ? Constant.textSecondary
        : (isUp == upIsGood
              ? Constant.incomeGreenAccentDark
              : Constant.expenseRed);

    final String text = !hasPrev
        ? 'Belum ada data pembanding'
        : isFlat
        ? 'Sama seperti sebelumnya'
        : '${isUp ? 'Naik' : 'Turun'} ${pct.abs().toStringAsFixed(1)}%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Constant.textPrimary,
              ),
            ),
            Text(
              'Sebelumnya ${Utils.formatIDR(previous)}',
              style: const TextStyle(
                fontSize: 11,
                color: Constant.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (hasPrev && !isFlat)
              Icon(
                isUp ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                size: 16,
                color: color,
              ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
