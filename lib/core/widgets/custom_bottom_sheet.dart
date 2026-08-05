import 'package:flutter/material.dart';

class CustomBottomSheet {
  // ================= STANDARD BOTTOM SHEET =================
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }

  // ================= LIST BOTTOM SHEET =================
  static Future<T?> list<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetItem<T>> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => ListTile(
              leading: item.icon != null ? Icon(item.icon) : null,
              title: Text(item.title),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () => Navigator.pop(context, item.value),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ================= MENU BOTTOM SHEET =================
  static Future<T?> menu<T>({
    required BuildContext context,
    required List<MenuBottomSheetItem<T>> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.icon, color: item.color),
              title: Text(item.title, style: TextStyle(color: item.color)),
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ================= BOTTOM SHEET MODELS =================
class BottomSheetItem<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;

  BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}

class MenuBottomSheetItem<T> {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  MenuBottomSheetItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });
}
