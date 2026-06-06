import 'package:flutter/material.dart';
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

  final _screens = const [
    KaprodiDashboard(),
    KaprodiAssignment(),   // Tab baru: kelola assignment kaprodi
    KaprodiVerifikasi(),   // Tab baru: verifikasi bukti kompen mahasiswa
    KaprodiApproval(),     // Tab lama: approval pengajuan masuk
    NotifikasiScreen(),
    ProfilScreen(),
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
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded),
              label: 'Verifikasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified_rounded),
              label: 'Approval',
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