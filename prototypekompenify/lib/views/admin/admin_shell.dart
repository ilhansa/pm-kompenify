// lib/views/admin/admin_shell.dart
// Menggunakan AuthController untuk sinkronisasi jumlah badge notifikasi real-time area admin

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/auth_controller.dart'; // ✅ Menggunakan AuthController pusat
import '../../utils/app_theme.dart';
import 'admin_dashboard.dart';
import 'admin_users.dart';
import '../shared/notifikasi_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _idx = 0;

  // Daftar susunan halaman utama Admin (Pas 3 menu paralel)
  final _screens = const [AdminDashboard(), AdminUsers(), NotifikasiScreen()];

  @override
  Widget build(BuildContext context) {
    // Mengambil state unreadCount terpusat dari REST API Laravel via AuthController
    final authController = context.watch<AuthController>();
    final unread = authController.unreadCount;

    return Scaffold(
      body: _screens[_idx],
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
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Pengguna',
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
          ],
        ),
      ),
    );
  }
}
