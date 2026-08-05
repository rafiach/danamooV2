import 'package:flutter/material.dart';

class CustomAppBar {
  // ================= STANDARD APP BAR =================
  static PreferredSizeWidget standard({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? const Color(0xFF212121),
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? const Color(0xFF212121),
      elevation: elevation,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  // ================= TRANSPARENT APP BAR =================
  static PreferredSizeWidget transparent({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? foregroundColor,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
      leading: leading,
      actions: actions,
    );
  }

  // ================= SEARCH APP BAR =================
  static PreferredSizeWidget search({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? hint,
    VoidCallback? onClear,
    Color? backgroundColor,
  }) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint ?? 'Cari...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}
