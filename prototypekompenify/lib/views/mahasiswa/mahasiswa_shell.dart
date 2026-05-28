import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIREBASE FIRESTORE
import '../../utils/app_theme.dart';
import '../../models/mahasiswa_model.dart'; 
import 'mahasiswa_dashboard.dart';
import 'assignment_list.dart';
import 'kompen_saya.dart';
import '../shared/notifikasi_screen.dart';
import '../shared/profil_screen.dart';

class MahasiswaShell extends StatefulWidget {
  final MahasiswaModel mahasiswa;

  const MahasiswaShell({super.key, required this.mahasiswa});

  @override
  State<MahasiswaShell> createState() => _MahasiswaShellState();
}

class _MahasiswaShellState extends State<MahasiswaShell> {
  int _idx = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      MahasiswaDashboard(mahasiswa: widget.mahasiswa), 
      AssignmentListScreen(mahasiswa: widget.mahasiswa), 
      KompenSayaScreen(mahasiswa: widget.mahasiswa), // <-- UBAH JADI GINI (Hapus kata const-nya)
      const NotifikasiScreen(),
      const ProfilScreen(), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 2. GUNAKAN STREAMBUILDER UNTUK MENGHITUNG NOTIFIKASI BELUM DIBACA SECARA REALTIME
    return StreamBuilder<QuerySnapshot>(
      // Mengintip ke koleksi 'notifications' milik mahasiswa ini yang field 'sudahDibaca' bernilai false
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: widget.mahasiswa.id)
          .where('sudahDibaca', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        // Jika data belum siap, set angka unread sementara ke 0
        int unread = 0;
        if (snapshot.hasData) {
          unread = snapshot.data!.docs.length; // Hitung jumlah dokumen notif yang belum dibaca
        }

        return Scaffold(
          body: IndexedStack(
            index: _idx,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary);
                }
                return const TextStyle(fontSize: 12, color: AppTheme.textMuted);
              }),
            ),
            child: NavigationBar(
              backgroundColor: AppTheme.surface,
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
                
                // TAB NOTIFIKASI DENGAN BADGE REALTIME FIREBASE
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
      },
    );
  }
}