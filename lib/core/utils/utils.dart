import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../generated/assets.dart';
import '../constants/constant.dart';

class Utils {
  // ================= FORMATTER - CURRENCY =================

  /// Format Currency IDR (Contoh: Rp 10.000)
  static String formatIDR(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  /// Format Currency IDR with decimals (Contoh: Rp 10.000,50)
  static String formatIDRWithDecimal(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );
    return format.format(value);
  }

  /// Format Currency USD (Contoh: $10,000.00)
  static String formatUSD(double value) {
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$ ',
      decimalDigits: 2,
    );
    return format.format(value);
  }

  /// Format number with thousand separator (Contoh: 10.000)
  static String formatNumber(double value, {int decimalDigits = 0}) {
    final format = NumberFormat.decimalPattern('id_ID');
    if (decimalDigits > 0) {
      return value.toStringAsFixed(decimalDigits).replaceAll('.', ',');
    }
    return format.format(value);
  }

  /// Format compact number (Contoh: 1.5K, 2.3M)
  static String formatCompactNumber(double value) {
    final format = NumberFormat.compact(locale: 'id_ID');
    return format.format(value);
  }

  // ================= FORMATTER - DATE & TIME =================

  /// Format Tanggal (Contoh: 17 Agustus 2023)
  static String formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Format Tanggal Pendek (Contoh: 17 Agu 2023)
  static String formatDateShort(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  /// Format Tanggal dengan Hari (Contoh: Kamis, 17 Agustus 2023)
  static String formatDateWithDay(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Format Time (Contoh: 14:30)
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format DateTime to Time (Contoh: 14:30)
  static String formatDateTimeToTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format DateTime Complete (Contoh: 17 Agustus 2023, 14:30)
  static String formatDateTimeComplete(DateTime dateTime) {
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  /// Format Relative Time (Contoh: 2 jam yang lalu, kemarin, dll)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    }
  }

  // ================= VALIDATOR =================

  /// Validate Email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate Phone Number (Indonesia format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Validate Password (min 8 characters, at least 1 uppercase, 1 lowercase, 1 number)
  static bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Validate URL
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(url);
  }

  /// Check if string is numeric
  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Check if string is empty or whitespace only
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // ================= STRING MANIPULATION =================

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Capitalize first letter only
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Remove HTML tags from string
  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Format phone number to Indonesia format (Contoh: 0812-3456-7890)
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 10) return phone;

    if (cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    } else if (cleaned.startsWith('62')) {
      return '+${cleaned.substring(0, 2)}-${cleaned.substring(2, 5)}-${cleaned.substring(5, 9)}-${cleaned.substring(9)}';
    }
    return phone;
  }

  // ================= PICKER =================

  /// Pick Date
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  /// Pick Time
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  /// Pick Date Range
  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  // ================= DIALOG & SNACKBAR =================

  /// Show Alert Dialog
  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(buttonText ?? "OK"),
          ),
        ],
      ),
    );
  }

  /// Show Success Dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _showStatusDialog(
      context,
      title: title,
      content: content,
      imagePath: Assets.assetsIconsSuccess,
      iconData: Icons.check_circle_outline,
      iconColor: Colors.green,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show Error Dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _showStatusDialog(
      context,
      title: title,
      content: content,
      imagePath: Assets.assetsIconsError,
      iconData: Icons.error_outline,
      iconColor: Colors.red,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show Warning Dialog
  static Future<void> showWarningDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _showStatusDialog(
      context,
      title: title,
      content: content,
      imagePath: Assets.assetsIconsWarning,
      iconData: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Internal Base Dialog for Status
  static Future<void> _showStatusDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
    required IconData iconData,
    required Color iconColor,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null)
                Image.asset(imagePath, width: 100, height: 100)
              else
                Icon(iconData, size: 80, color: iconColor),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onPressed ?? () => Navigator.pop(context),
                  child: Text(
                    buttonText ?? "OK",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show Confirmation Dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? "Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDanger
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText ?? "OK"),
          ),
        ],
      ),
    );
  }

  /// Show Loading Dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showAutoDismissDialog(
    BuildContext context, {
    required String title,
    required String content,
    Duration duration = const Duration(seconds: 2),
    String? imagePath,
    IconData iconData = Icons.check_circle,
    Color iconColor = Colors.green,
    VoidCallback? onDismissed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null)
                  Image.asset(imagePath, width: 100, height: 100)
                else
                  Icon(iconData, color: iconColor, size: 64),
                const SizedBox(height: 16),
                Text(title, style: Constant.h3),
                const SizedBox(height: 8),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Constant.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Tutup dialog otomatis setelah durasi tertentu
    return Future.delayed(duration, () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      onDismissed?.call();
    });
  }

  /// Hide Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// Show Success Snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Error Snackbar
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Info Snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Warning Snackbar
  static void showWarningSnackbar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Bottom Sheet
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }

  // ================= NAVIGATION =================

  /// Navigate to page
  static Future<T?> navigateTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigate and replace current page
  static Future<T?> navigateReplaceTo<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, void>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigate and remove all previous pages
  static Future<T?> navigateRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  // ================= CLIPBOARD =================

  /// Copy to clipboard
  static Future<void> copyToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  /// Get from clipboard
  static Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  // ================= DEVICE INFO =================

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get bottom navigation bar height
  static double getBottomBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // ================= KEYBOARD =================

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // ================= DELAY & DEBOUNCE =================

  /// Delay execution
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  /// Simple debouncer
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // ================= FILE SIZE =================

  /// Format file size (Contoh: 1.5 MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ================= COLOR =================

  /// Convert hex color to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    final r = (color.r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');

    return '#$r$g$b';
  }

  // ================= RANDOM =================

  /// Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length],
    ).join();
  }

  // Empty state
  static Center emptyState(
    String imagePath,
    String header,
    String description, {
    double imageWidth = 200,
    double imageHeight = 200,
    Color textColor = Colors.grey,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              header,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
