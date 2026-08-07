import 'package:danamoo/core/services/notification_service.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/repositories/auth_repository.dart';
import 'package:danamoo/data/repositories/sync_repository.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/features/auth/provider/auth_provider.dart';
import 'package:danamoo/features/auth/view/login_view.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = await StorageService.getInstance();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    // Buat instance repository sekali, dipakai bersama antar provider
    final authRepository = AuthRepository(storage);
    final syncRepository = SyncRepository(storage);
    final transactionRepository = TransactionRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initService(storage),
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
          colorSchemeSeed: const Color(0xFF2196F3),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF212121),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
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
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
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
