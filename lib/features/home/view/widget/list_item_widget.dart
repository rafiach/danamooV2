import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/widgets/custom_card.dart';

class ListTileTransaction extends StatelessWidget {
  final String label;
  final String nominal;
  final String date;
  final String icon;
  final Color? nominalColor;
  final bool isIncome;

  const ListTileTransaction({
    super.key,
    required this.label,
    required this.nominal,
    required this.date,
    required this.icon,
    this.nominalColor,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor =
        nominalColor ?? (isIncome ? Constant.limeAccent : Constant.expenseRed);

    return CustomCard.surface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Constant.limeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              // child: ColorFiltered(
              //   colorFilter: const ColorFilter.mode(
              //     Constant.limeAccent,
              //     BlendMode.srcIn,
              //   ),
              //   child: Image.asset(icon, width: 22, height: 22),
              // ),
              child: Image.asset(icon, width: 22, height: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Constant.textSemiBold.copyWith(
                    color: Constant.textPrimary,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: Constant.caption.copyWith(
                    color: Constant.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nominal,
            style: Constant.textSemiBold.copyWith(
              color: amountColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
