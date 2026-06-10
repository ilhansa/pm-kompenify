// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── PERBAIKAN IMPORT PATH (Menggunakan relative path yang benar dari posisi main.dart) ───
import 'controllers/auth_controller.dart';
import 'controllers/mahasiswa_controller.dart';
import 'controllers/dosen_controller.dart';
import 'controllers/kaprodi_controller.dart';

import 'utils/app_theme.dart';
// import 'views/auth/login_screen.dart';
import 'views/splash_screen.dart'; // ✅ Jalur disesuaikan dengan struktur folder luar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file konfigurasi lingkungan (.env)
  await dotenv.load(fileName: ".env");

  // Mengatur gaya visual status bar sistem Android (Diubah ke Brightness.dark agar ikon jam/baterai kelihatan di tema putih)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── MENGGUNAKAN MULTIPROVIDER UNTUK MANAJEMEN BANYAK KONTROLER ───
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
        theme: AppTheme
            .lightTheme, // ✅ Sudah sinkron menggunakan lightTheme Google yang baru
        home:
            const SplashScreen(), // ✅ Diubah ke SplashScreen agar alur aplikasi dimulai dari awal ring splash screen
      ),
    );
  }
}
