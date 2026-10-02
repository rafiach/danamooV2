import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/constant.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../data/models/category_model.dart';
import '../../../../core/widgets/custom_navigator.dart';
import '../../../../core/widgets/segmented_control.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../history/view/history_view.dart';
import '../../provider/insight_provider.dart';

class SpendingTab extends StatefulWidget {
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final DateTime month;

  const SpendingTab({
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.month,
    super.key,
  });

  @override
  State<SpendingTab> createState() => _SpendingTabState();
}

class _SpendingTabState extends State<SpendingTab> {
  int _touchedIndex = -1;
  bool _showIncome = false;

  // Semua kategori income berwarna sama di CategoryModel, jadi pie butuh palet sendiri
  static const _incomePalette = [
    Constant.incomeGreenAccentDark,
    Constant.limeAccentDark,
    Color(0xFF3A86FF),
    Color(0xFF9B5DE5),
    Color(0xFFFF9F1C),
    Color(0xFF06D6A0),
  ];

  Color _colorFor(String id) {
    if (!_showIncome) {
      return CategoryModel.getById(id)?.color ?? Constant.otherPrime;
    }
    final i = CategoryModel.incomeCategories.indexWhere((c) => c.id == id);
    return _incomePalette[(i < 0 ? 0 : i) % _incomePalette.length];
  }

  String _nameFor(String id) => CategoryModel.getById(id)?.name ?? 'Lainnya';
  Future<void> _openDetail(String id) async {
    final category = CategoryModel.getById(id);
    if (category == null) return;

    await CustomNavigator.push(
      context,
      HistoryView(
        initialType: _showIncome ? 'Pemasukan' : 'Pengeluaran',
        initialCategory: category.name,
        initialMonth: widget.month,
      ),
    );

    // Transaksi bisa diedit/dihapus di History, segarkan angka tanpa spinner
    if (!mounted) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<InsightProvider>().fetchMonthlyData(user, silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = _showIncome
        ? widget.incomeByCategory
        : widget.expenseByCategory;
    final entries = source.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final double total = entries.fold(0, (sum, e) => sum + e.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SegmentedControl(
            labels: const ['Pengeluaran', 'Pemasukan'],
            selectedIndex: _showIncome ? 1 : 0,
            onChanged: (i) => setState(() {
              _showIncome = i == 1;
              _touchedIndex = -1;
            }),
            borderRadius: 24,
            height: 44,
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _buildEmptyState()
          else ...[
            _buildChartCard(entries, total),
            const SizedBox(height: 16),
            _buildLegendGrid(entries, total),
            const SizedBox(height: 12),
            const Text(
              'Ketuk kategori untuk melihat transaksinya.',
              style: TextStyle(fontSize: 11, color: Constant.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartCard(List<MapEntry<String, double>> entries, double total) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              _showIncome ? 'Sumber Pemasukan' : 'Spending Breakdown',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Constant.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 250,
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
                              _touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 58,
                      sections: List.generate(entries.length, (i) {
                        final isTouched = i == _touchedIndex;
                        final pct = entries[i].value / total * 100;
                        return PieChartSectionData(
                          color: _colorFor(entries[i].key),
                          value: entries[i].value,
                          title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Constant.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Utils.formatCompactNumber(total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Constant.textPrimary,
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
    );
  }

  Widget _buildLegendGrid(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final id = entries[i].key;
        final pct = entries[i].value / total * 100;
        return CustomCard.surface(
          borderRadius: 16,
          padding: const EdgeInsets.all(12),
          onTap: () => _openDetail(id),
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
                      color: _colorFor(id),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _nameFor(id),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Constant.textPrimary,
                      ),
                      maxLines: 2,
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
                  color: Constant.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Constant.incomeGreenAccentDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
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
