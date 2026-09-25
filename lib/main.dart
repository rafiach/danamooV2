import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:danamoo/core/constants/constant.dart';
import 'package:danamoo/core/services/notification_service.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/repositories/auth_repository.dart';
import 'package:danamoo/data/repositories/sync_repository.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/features/auth/provider/auth_provider.dart';
import 'package:danamoo/features/auth/view/login_view.dart';
import 'package:danamoo/features/history/provider/history_provider.dart';
import 'package:danamoo/features/home/provider/home_provider.dart';
import 'package:danamoo/features/home/view/home_view.dart';
import 'package:danamoo/features/insight/provider/insight_provider.dart';
import 'package:danamoo/features/profile/provider/profile_provider.dart';
import 'package:danamoo/features/splash/view/splash_view.dart';
import 'package:danamoo/features/transaction/provider/transaction_provider.dart';
import 'package:danamoo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:danamoo/core/services/widget_callback_service.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.setLoggingEnabled(true);
  await NotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Constant.bgNeutral,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = await StorageService.getInstance();
  await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(storage);
    final syncRepository = SyncRepository(storage);
    final transactionRepository = TransactionRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider()..initService(storage, transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              HomeProvider(transactionRepository: transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(transactionRepository: transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              HistoryProvider(transactionRepositori: transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              InsightProvider(transactionRepository: transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            authRepository: authRepository,
            syncRepository: syncRepository,
            transactionRepository: transactionRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Danamoo',
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationService.navigatorKey,

        // ================= THEME =================
        theme: ThemeData(
          colorSchemeSeed: Constant.limeAccent,
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: Constant.surfaceCard,
            foregroundColor: Constant.textPrimary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Constant.textPrimary,
            ),
          ),
          scaffoldBackgroundColor: Constant.bgNeutral,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.limeAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Constant.bgSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Constant.limeAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Constant.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        home: const AuthWrapper(),
      ),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
        return const SplashView();
      case AuthStatus.loading:
        return const SplashView();
      case AuthStatus.authenticated:
        return const HomeView();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginView();
    }
  }
}
