import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/constant.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      },
    );

    // Meminta izin (Prompt) khusus untuk Android 13 ke atas
    await _notificationsPlugin.resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin()?.requestNotificationsPermission();
  }

  static Future<void> showTransactionNotification({
    required int id,
    required String title,
    required String body,
    required bool isIncome,
  }) async {
    final Color accentColor = isIncome
        ? Constant.limeAccent
        : Constant.expenseRed;

    final AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'transaction_channel',
      'Transaksi',
      channelDescription: 'Notifikasi untuk setiap transaksi baru',
      importance: Importance.max,
      priority: Priority.high,
      icon:
          '@mipmap/ic_launcher', // ganti '@drawable/ic_notification' kalau sudah ada asset khusus
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: accentColor,
      colorized: true,
      ticker: title,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: isIncome ? 'Pemasukan' : 'Pengeluaran',
        htmlFormatContentTitle: false,
        htmlFormatBigText: false,
      ),
      category: AndroidNotificationCategory.status,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      playSound: true,
      enableVibration: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
