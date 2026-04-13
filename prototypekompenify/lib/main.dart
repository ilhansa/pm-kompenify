import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'dashboard_mahasiswa.dart';
import 'profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kompenify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Seed dari indigo biar konsisten sama design system
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginPage(),
        '/dashboard': (ctx) => const DashboardMahasiswaPage(),
        '/profile': (ctx) => const ProfilePage(),
      },
      // Animasi transisi antar halaman yang smooth
      onGenerateRoute: (settings) {
        final routes = {
          '/': const SplashScreen(),
          '/login': const LoginPage(),
          '/dashboard': const DashboardMahasiswaPage(),
          '/profile': const ProfilePage(),
        };
        final page = routes[settings.name];
        if (page == null) return null;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    );
  }
}
