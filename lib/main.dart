import 'package:danamoo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/features/auth/view/login_view.dart';
import 'package:danamoo/features/splash/view/splash_view.dart';
import 'package:danamoo/features/auth/provider/auth_provider.dart';
import 'package:danamoo/features/home/view/home_view.dart';

void main() async {
  // ================= INIT =================
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null);

  // Paksa orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Atur tampilan status bar & navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Init SharedPreferences
  final storage = await StorageService.getInstance();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initService(storage),
        ),
        // Tambahkan provider lain di sini nanti
        // ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Template',
        debugShowCheckedModeBanner: false,

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

        // ================= AUTH WRAPPER =================
        // Status initial → SplashView (SplashView yang panggil checkSession)
        // Status authenticated → HomeView
        // Status unauthenticated/error → LoginView
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
        // Selalu mulai dari SplashView
        // SplashView yang bertanggung jawab panggil checkSession()
        return const SplashView();

      case AuthStatus.loading:
        // Tetap di SplashView saat checkSession() berjalan
        return const SplashView();

      case AuthStatus.authenticated:
        return const HomeView();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginView();
    }
  }
}
