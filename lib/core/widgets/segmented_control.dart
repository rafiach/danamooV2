import 'package:flutter/material.dart';
import '../constants/constant.dart';

class SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;

  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.borderRadius = 24,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = activeColor ?? Constant.limeAccent;
    final inactiveBg = inactiveColor ?? Colors.transparent;
    final activeText = Constant.textWhite;
    final inactiveText = Constant.textSecondary;
    final bg = backgroundColor ?? Constant.surfaceCard;
    final border = Constant.borderSubtle;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: Constant.durationShort,
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : inactiveBg,
                  borderRadius: BorderRadius.circular(borderRadius - 4),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? activeText : inactiveText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}