import 'package:flutter/material.dart';
import 'package:danamoo/data/models/category_model.dart';
import '../constants/constant.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Constant.durationShort,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Constant.limeAccentDark.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Constant.limeAccentDark : Constant.borderSubtle,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            category.icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Constant.textPrimary
                      : Constant.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
