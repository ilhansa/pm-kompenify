import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── IMPOR CONTROLLERS BARU YANG SUDAH DIPISAH ───
import 'controllers/auth_controller.dart';
import 'controllers/mahasiswa_controller.dart';
import 'controllers/dosen_controller.dart';
import 'controllers/kaprodi_controller.dart';

import 'utils/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file konfigurasi lingkungan (.env)
  await dotenv.load(fileName: ".env");

  // Mengatur gaya visual status bar sistem Android
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
    // ─── MENGGUNAKAN MULTIPROVIdER UNTUK MANAJEMEN BANYAK KONTROLER ───
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => MahasiswaController()),
        ChangeNotifierProvider(create: (_) => DosenController()),
        ChangeNotifierProvider(create: (_) => KaprodiController()),
      ],
      child: MaterialApp(
        title: 'Kompenify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}