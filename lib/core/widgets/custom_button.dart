import 'package:flutter/material.dart';

class CustomButton {
  // ================= MAIN BUTTON =================
  static Widget mainButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Color? color,
    Color? textColor,
    IconData? icon,
    double height = 48,
    double borderRadius = 12,
    double fontSize = 14,
    double? width,
  }) {
    final isDisabled = !enabled || isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // Warna saat disabled lebih proper pakai withValues
          disabledBackgroundColor:
              color?.withValues(alpha: 0.4) ??
              Colors.grey.withValues(alpha: 0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _mainContent(
          label: label,
          isLoading: isLoading,
          textColor: textColor ?? Colors.white,
          icon: icon,
          fontSize: fontSize,
        ),
      ),
    );
  }

  // ================= BORDER BUTTON =================
  static Widget borderButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Color? color,
    IconData? icon,
    double height = 48,
    double borderRadius = 12,
    double fontSize = 14,
    double borderWidth = 1.5,
    double? width,
  }) {
    final isDisabled = !enabled || isLoading || onPressed == null;
    final activeColor = color ?? const Color(0xFF2196F3);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: activeColor,
          // Warna saat disabled
          disabledForegroundColor: activeColor.withValues(alpha: 0.4),
          side: BorderSide(
            color: isDisabled
                ? activeColor.withValues(alpha: 0.4)
                : activeColor,
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _mainContent(
          label: label,
          isLoading: isLoading,
          textColor: isDisabled
              ? activeColor.withValues(alpha: 0.4)
              : activeColor,
          icon: icon,
          fontSize: fontSize,
        ),
      ),
    );
  }

  // ================= TEXT BUTTON =================
  static Widget textButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Color? color,
    IconData? icon,
    double fontSize = 14,
    TextDecoration? decoration,
  }) {
    final isDisabled = !enabled || isLoading || onPressed == null;
    final activeColor = color ?? const Color(0xFF2196F3);

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: activeColor,
        disabledForegroundColor: activeColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: _mainContent(
        label: label,
        isLoading: isLoading,
        textColor: isDisabled
            ? activeColor.withValues(alpha: 0.4)
            : activeColor,
        icon: icon,
        fontSize: fontSize,
        decoration: decoration,
      ),
    );
  }

  // ================= ICON BUTTON =================
  static Widget iconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Color? color,
    Color? backgroundColor,
    double iconSize = 22,
    String? tooltip,
  }) {
    final isDisabled = !enabled || isLoading || onPressed == null;
    final activeColor = color ?? const Color(0xFF2196F3);

    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      iconSize: iconSize,
      color: activeColor,
      disabledColor: activeColor.withValues(alpha: 0.4),
      tooltip: tooltip,
      style: IconButton.styleFrom(backgroundColor: backgroundColor),
      icon: isLoading
          ? SizedBox(
              width: iconSize * 0.85,
              height: iconSize * 0.85,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDisabled
                    ? activeColor.withValues(alpha: 0.4)
                    : activeColor,
              ),
            )
          : Icon(icon),
    );
  }

  // ================= ICON ONLY (Bulat/Kotak dengan background) =================
  static Widget iconFilled({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Color? color,
    Color? iconColor,
    double size = 44,
    double iconSize = 20,
    double borderRadius = 12,
    String? tooltip,
  }) {
    final isDisabled = !enabled || isLoading || onPressed == null;
    final bgColor = color ?? const Color(0xFF2196F3);

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: isDisabled ? bgColor.withValues(alpha: 0.4) : bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor ?? Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SHARED CONTENT =================
  static Widget _mainContent({
    required String label,
    required bool isLoading,
    required Color textColor,
    IconData? icon,
    double fontSize = 14,
    TextDecoration? decoration,
  }) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    }

    // Jika ada icon, tampilkan icon + label
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: fontSize + 4, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              decoration: decoration,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        decoration: decoration,
      ),
    );
  }
}
