import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'dashboard_mahasiswa.dart';
import 'profile.dart';
import 'notification_page.dart';
<<<<<<< HEAD
import 'avaliable_jobs_page.dart';
=======
import 'upload_page.dart';
import 'avaliable_jobs_page.dart';
// 1. Tambahkan baris import ini
>>>>>>> upload_page

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
      onGenerateRoute: (settings) {
        final Map<String, Widget> routes = {
<<<<<<< HEAD
          '/': const SplashScreen(),
          '/login': const LoginPage(),
          '/dashboard': const DashboardMahasiswaPage(),
          '/available_jobs': const AvailableJobsPage(),
          '/profile': const ProfilePage(),
          '/notifications': const NotificationPage(),
        };
=======
  '/': const SplashScreen(),
  '/login': const LoginPage(),
  '/dashboard': const DashboardMahasiswaPage(),
  '/profile': const ProfilePage(),
  '/notifications': const NotificationPage(),
  '/upload': const UploadPage(),
  '/available_jobs': const AvailableJobsPage(), // Tambahkan baris ini
};
>>>>>>> upload_page

        final Widget? page = routes[settings.name];

        if (page == null) return null;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, anim, secondaryAnimation, child) {
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
<<<<<<< HEAD
}
=======
}
>>>>>>> upload_page
