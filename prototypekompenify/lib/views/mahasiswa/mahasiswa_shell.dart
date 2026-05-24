import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../../utils/app_theme.dart';
import '../../models/mahasiswa_model.dart'; // 1. Wajib import model mahasiswamu
import 'mahasiswa_dashboard.dart';
import 'assignment_list.dart';
import 'kompen_saya.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';

class MahasiswaShell extends StatefulWidget {
  // 2. Tambahkan parameter untuk menerima lemparan data dari login_screen
  final MahasiswaModel mahasiswa;

  const MahasiswaShell({super.key, required this.mahasiswa});

  @override
  State<MahasiswaShell> createState() => _MahasiswaShellState();
}

class _MahasiswaShellState extends State<MahasiswaShell> {
  int _idx = 0;

  // 3. Hapus kata 'const' di sini karena list ini sekarang dinamis berisi data objek
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 4. Inisialisasi halaman-halaman dan oper data 'widget.mahasiswa' ke dashboard
    _screens = [
      MahasiswaDashboard(mahasiswa: widget.mahasiswa), // Dashboard baru menerima data Firebase
      const AssignmentListScreen(),
      const KompenSayaScreen(),
      const NotifikasiScreen(),
      const ProfilScreen(), // Nanti jika profil butuh data, tinggal oper widget.mahasiswa juga
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 5. Matikan atau set sementara unread = 0 agar tidak memanggil DataService lama yang bikin crash.
    // Nanti bagian notifikasi ini bisa kamu hubungkan ke Firestore terpisah.
    int unread = 0; 

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