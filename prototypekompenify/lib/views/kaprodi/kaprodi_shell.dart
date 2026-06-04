import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'kaprodi_dashboard.dart';
import 'kaprodi_approval.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';

// ─── Kaprodi Shell (Navigasi Utama) ───────────────────────────────────────────
class KaprodiShell extends StatefulWidget {
  const KaprodiShell({super.key});

  @override
  State<KaprodiShell> createState() => _KaprodiShellState();
}

class _KaprodiShellState extends State<KaprodiShell> {
  int _idx = 0;
  
  // Daftarkan semua layar segmen di sini
  final _screens = const [
    KaprodiDashboard(),
    KaprodiApproval(),
    NotifikasiScreen(),
    ProfilScreen(), // Layar Profil Shared
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard, 
          border: Border(top: BorderSide(color: AppTheme.divider))
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          indicatorColor: AppTheme.primary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified_rounded), label: 'Approval'),
            NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}