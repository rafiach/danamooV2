import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/constant.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../data/models/category_model.dart';

class SpendingTab extends StatefulWidget {
  final Map<String, double> spendingByCategory;

  const SpendingTab({required this.spendingByCategory, super.key});

  @override
  State<SpendingTab> createState() => _SpendingTabState();
}

class _SpendingTabState extends State<SpendingTab> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final double total = entries.fold(0, (sum, e) => sum + e.value);
    final bool empty = widget.spendingByCategory.isEmpty;

    if (empty) {
      return _buildEmptyState();
    }

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
                    'Spending Breakdown',
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
                              // Get category color from CategoryModel
                              final categoryName = entries[i].key;
                              final category = CategoryModel.expenseCategories
                                  .firstWhere(
                                    (c) => c.name == categoryName,
                                    orElse: () =>
                                        CategoryModel.expenseCategories.first,
                                  );
                              final color = category.color;
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
                        // Center label - Always show Total
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Constant.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
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
          ),
          const SizedBox(height: 16),

          // Legend Grid
          GridView.builder(
            // padding: const EdgeInsets.symmetric(horizontal: 16),
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
              final categoryName = entries[i].key;
              final category = CategoryModel.expenseCategories.firstWhere(
                (c) => c.name == categoryName,
                orElse: () => CategoryModel.expenseCategories.first,
              );
              final color = category.color;
              final pct = entries[i].value / total * 100;
              return CustomCard.surface(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
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
