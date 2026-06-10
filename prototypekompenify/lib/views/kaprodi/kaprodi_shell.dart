// lib/views/kaprodi/kaprodi_shell.dart
// Menggunakan AuthController untuk sinkronisasi jumlah badge notifikasi real-time area kaprodi

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import 'kaprodi_dashboard.dart';
import 'kaprodi_approval.dart';
import 'kaprodi_assignment.dart';
import 'kaprodi_verifikasi.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';

class KaprodiShell extends StatefulWidget {
  const KaprodiShell({super.key});

  @override
  State<KaprodiShell> createState() => _KaprodiShellState();
}

class _KaprodiShellState extends State<KaprodiShell> {
  int _idx = 0;

  // Daftar susunan halaman utama pimpinan (Total pas 6 halaman paralel)
  final _screens = const [
    KaprodiDashboard(),
    KaprodiAssignment(), // Mengelola tugas mandiri dari Kaprodi
    KaprodiVerifikasi(), // Memvalidasi bukti fisik pengerjaan tugas dari Kaprodi
    KaprodiApproval(), // Meja utama pengesahan E-TTD berkas akhir mahasiswa
    NotifikasiScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Mengambil state jumlah notifikasi belum dibaca secara real-time dari AuthController
    final authController = context.watch<AuthController>();
    final unread = authController.unreadCount;

    return Scaffold(
      body: _screens[_idx],
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
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded),
              label: 'Verifikasi',
            ),
            const NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified_rounded),
              label: 'Approval',
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
