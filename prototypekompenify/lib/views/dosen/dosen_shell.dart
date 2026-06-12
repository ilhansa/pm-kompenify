// lib/views/dosen/dosen_shell.dart
// Menggunakan AuthController untuk sesi dan badge notifikasi global area dosen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';
import 'dosen_dashboard.dart';
import 'dosen_assignment.dart';
import 'dosen_verifikasi.dart';

class DosenShell extends StatefulWidget {
  const DosenShell({super.key});

  @override
  State<DosenShell> createState() => __DosenShellState();
}

class __DosenShellState extends State<DosenShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    // Mengambil state jumlah notifikasi belum dibaca secara real-time dari AuthController
    final authController = context.watch<AuthController>();
    final unread = authController.unreadCount;

    // 🚀 SAKTI: Ubah screens jadi dinamis agar fungsi onNavigateToTab milik profil bisa didengar jink!
    final screens = [
      const DosenDashboard(),
      const DosenAssignment(),
      const DosenVerifikasi(), // Proses verifikasi & E-TTD disatukan di halaman ini
      const NotifikasiScreen(),
      ProfilScreen(
        onNavigateToTab: (indexBaru) {
          setState(() {
            _idx = indexBaru;
          });
        },
      ),
    ];

    return Scaffold(
      body: screens[_idx], // 👈 Mengambil index dinamis dari variabel lorr
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          indicatorColor: AppTheme.primary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Assignment',
            ),
            const NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified_rounded),
              label: 'Verifikasi',
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
