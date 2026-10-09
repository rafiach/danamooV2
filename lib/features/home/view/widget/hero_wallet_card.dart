import 'package:danamoo/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';

class HeroWalletCard extends StatelessWidget {
  final String label;
  final String balance;
  final String income;
  final String expense;
  final IconData icon;
  final Color accent;

  const HeroWalletCard({
    super.key,
    required this.label,
    required this.balance,
    required this.income,
    required this.expense,
    required this.icon,
    this.accent = Constant.limeAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard.hero(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      borderColor: Constant.greyDark.withValues(alpha: 0.5),
      color: Constant.greyDark.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Constant.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance,
                    style: Constant.h2.copyWith(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2),
                ),
                child: Center(child: Icon(icon, color: accent, size: 36)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(
            thickness: 1,
            color: Constant.greyDark.withValues(alpha: 0.5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Income
                _cashFlowItem(
                  'Income',
                  income,
                  Constant.incomeGreenAccent,
                  Icons.arrow_downward,
                ),
                // Divider tengah
                Container(
                  width: 1,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                // Expense
                _cashFlowItem(
                  'Expense',
                  expense,
                  Constant.expenseRed,
                  Icons.arrow_upward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashFlowItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Constant.bodySmall.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Constant.textSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
