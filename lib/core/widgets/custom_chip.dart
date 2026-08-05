import 'package:flutter/material.dart';

class CustomChip {
  // ================= FILLED CHIP =================
  static Widget filled({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
    Color? color,
    Color? textColor,
  }) {
    final chipColor = color ?? const Color(0xFF2196F3);

    return Material(
      color: chipColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: chipColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? chipColor,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: 16, color: chipColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= OUTLINED CHIP =================
  static Widget outlined({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
    Color? color,
    Color? textColor,
  }) {
    final chipColor = color ?? const Color(0xFF2196F3);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: chipColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: chipColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? chipColor,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: 16, color: chipColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= STATUS CHIP =================
  static Widget status({required String label, required StatusType type}) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case StatusType.success:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case StatusType.warning:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case StatusType.error:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case StatusType.info:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

enum StatusType { success, warning, error, info }
