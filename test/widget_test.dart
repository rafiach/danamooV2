// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/main.dart';

void main() {
  testWidgets('App starts with SplashView smoke test', (
    WidgetTester tester,
  ) async {
    // 1. Setup Mock SharedPreferences agar StorageService bisa berjalan di test environment
    SharedPreferences.setMockInitialValues({});

    // 2. Initialize StorageService
    final storage = await StorageService.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(storage: storage));

    // Verify that SplashView is displayed (Cek keberadaan Logo atau Loading)
    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
