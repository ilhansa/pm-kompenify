// lib/views/mahasiswa/mahasiswa_shell.dart
// Menggunakan AuthController untuk sinkronisasi session dan badge notifikasi global

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import 'mahasiswa_dashboard.dart';
import 'assignment_list.dart';
import 'kompen_saya.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';

class MahasiswaShell extends StatefulWidget {
  const MahasiswaShell({super.key});

  @override
  State<MahasiswaShell> createState() => _MahasiswaShellState();
}

class _MahasiswaShellState extends State<MahasiswaShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    // Mengakses data real-time jumlah notifikasi masuk via AuthController
    final authController = context.watch<AuthController>();
    final unread = authController.unreadCount;

    // 🚀 SAKTI: Kita taruh daftar screen di sini agar bisa memberikan fungsi ganti indeks secara real-time jink!
    final screens = [
      const MahasiswaDashboard(),
      const AssignmentListScreen(),
      const KompenSayaScreen(),
      const NotifikasiScreen(),
      // DI SINI KITA LEMPAR LOGIKA PINDAH SHELL TAB NYA LORR!
      ProfilScreen(
        onNavigateToTab: (indexBaru) {
          setState(() {
            _idx = indexBaru;
          });
        },
      ),
    ];

    return Scaffold(
      body: screens[_idx], // Ambil list dinamis dari variabel di atas lorr
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          indicatorColor: AppTheme.primary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Assignment',
            ),
            const NavigationDestination(
              icon: Icon(Icons.task_alt_outlined),
              selectedIcon: Icon(Icons.task_alt_rounded),
              label: 'Kompen Saya',
            ),
            NavigationDestination(
              icon: badges.Badge(
                showBadge: unread > 0,
                badgeContent: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications_rounded),
              label: 'Notifikasi',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
