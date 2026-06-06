// lib/views/dosen/dosen_shell.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';
import 'dosen_dashboard.dart';
import 'dosen_assignment.dart';
import 'dosen_verifikasi.dart';
import 'halaman_ttd_digital.dart'; // 🚀 1. TAMBAHKAN IMPORT HALAMAN BARU LU

// ─── Dosen Shell ─────────────────────────────────────────────────────────────
class DosenShell extends StatefulWidget {
  const DosenShell({super.key});

  @override
  State<DosenShell> createState() => _DosenShellState();
}

class _DosenShellState extends State<DosenShell> {
  int _idx = 0;

  // 🚀 2. SUNTIKKAN HALAMAN TTD KE INDEKS NOMOR 3 (Samping Verifikasi)
  final _screens = const [
    DosenDashboard(),
    DosenAssignment(),
    DosenVerifikasi(),
    HalamanTtdDigital(), // <--- Masuk ke indeks 3
    NotifikasiScreen(), // <--- Geser ke indeks 4
    ProfilScreen(), // <--- Geser ke indeks 5
  ];

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Assignment',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified_rounded),
              label: 'Verifikasi',
            ),
            // 🚀 3. TAMBAHKAN ICON TOMBOL E-TTD DI NAVIGATION BAR
            NavigationDestination(
              icon: Icon(Icons.draw_outlined),
              selectedIcon: Icon(Icons.draw_rounded),
              label: 'E-TTD',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Notifikasi',
            ),
            NavigationDestination(
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
