import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/data_service.dart';
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

  final _screens = const [
    MahasiswaDashboard(),
    AssignmentListScreen(),
    KompenSayaScreen(),
    NotifikasiScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dataSvc = context.watch<DataService>();
    
    // 1. Konversi currentUser?.id ke String menggunakan .toString() agar singkron dengan fungsi statis
    final unread = dataSvc.getUnreadCount(
      dataSvc.currentUser?.id != null ? dataSvc.currentUser!.id.toString() : '',
    );

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