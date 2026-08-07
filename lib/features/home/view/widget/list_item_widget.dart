import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/widgets/custom_card.dart';

class ListItemWidget extends StatelessWidget {
  final String label;
  final String nominal;
  final String date;
  final String icon;
  final Color? color;
  final Color? nominalColor;

  const ListItemWidget({
    super.key,
    required this.label,
    required this.nominal,
    required this.date,
    required this.icon,
    this.color,
    this.nominalColor,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Constant.violet200;

    return CustomCard.elevated(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
            child: Image.asset(icon, width: 28, height: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Constant.textBold.copyWith(
                    color: Constant.violetDarker,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                Text(
                  date,
                  style: Constant.caption.copyWith(
                    color: Constant.violetDarker,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nominal,
            style: Constant.textBold.copyWith(
              color: nominalColor ?? Constant.error,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
