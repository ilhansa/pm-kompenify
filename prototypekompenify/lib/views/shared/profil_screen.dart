import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';
import '../../models/mahasiswa_model.dart'; 
import '../../controllers/auth_controller.dart'; // Import AuthController barumu

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Sesi habis, silakan login kembali.", style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic>? dataMentah = snapshot.data!.data() as Map<String, dynamic>?;

          if (dataMentah == null) {
            return const Scaffold(body: Center(child: Text("Data kosong")));
          }

          final dataTerbaru = MahasiswaModel.fromFirestore(snapshot.data!.id, dataMentah);

          int totalJamWajib = dataMentah['total_jam_kompen'] ?? 0;
          int sisaJam = dataMentah['sisa_jam_kompen'] ?? 0;
          
          int totalJamSelesai = totalJamWajib - sisaJam;
          if (totalJamSelesai < 0) totalJamSelesai = 0; 
          
          bool sudahLunas = sisaJam == 0;

          return GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const SizedBox(height: 20),
                  
                  // Avatar
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient, 
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)]
                    ),
                    child: Center(
                      child: Text(
                        dataTerbaru.nama.isNotEmpty ? dataTerbaru.nama[0] : 'U', 
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)
                      )
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dataTerbaru.nama.isNotEmpty ? dataTerbaru.nama : 'Nama Tidak Ditemukan', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), 
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 4),
                  
                  StatusBadge(
                    label: dataTerbaru.nama.isNotEmpty ? 'Mahasiswa' : 'User', 
                    color: AppTheme.accent
                  ),
                  const SizedBox(height: 4),
                  Text(dataTerbaru.nim, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  
                  const SizedBox(height: 28),
                  
                  _RekapRow(
                    totalJamSelesai: totalJamSelesai,
                    totalJamWajib: totalJamWajib,
                    sisaJam: sisaJam,
                    sudahLunas: sudahLunas,
                  ),
                  const SizedBox(height: 24),

                  // 1. MENU ITEM DENGAN JUMLAH DINAMIS MENGGUNAKAN FUTURE / STREAM AGREGAT SECARA LANGSUNG
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('pengajuan').where('mahasiswaId', isEqualTo: dataTerbaru.id).snapshots(),
                    builder: (context, s) => _menuItem(
                      Icons.assignment_outlined, 
                      'Riwayat Kompen', 
                      subtitle: '${s.data?.docs.length ?? 0} pengajuan'
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: dataTerbaru.id).where('sudahDibaca', isEqualTo: false).snapshots(),
                    builder: (context, s) => _menuItem(
                      Icons.notifications_outlined, 
                      'Notifikasi', 
                      subtitle: '${s.data?.docs.length ?? 0} belum dibaca'
                    ),
                  ),
                  
                  _menuItem(Icons.help_outline_rounded, 'Bantuan & FAQ'),
                  _menuItem(Icons.info_outline_rounded, 'Tentang Aplikasi'),
                  const SizedBox(height: 16),
                  
                  // Tombol Keluar terhubung langsung ke AuthController
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      onTap: () async {
                        // Jalankan fungsi logout resmi milik AuthController
                        await AuthController().logoutUser();
                        if (context.mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        }
                      },
                      leading: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
                      title: const Text('Keluar', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Dokumen profile tidak ditemukan di database.")),
        );
      },
    );
  }

  Widget _RekapRow({
    required int totalJamSelesai,
    required int totalJamWajib,
    required int sisaJam,
    required bool sudahLunas,
  }) {
    return Row(children: [
      Expanded(child: _statBox('$totalJamSelesai', 'Jam Selesai', AppTheme.accentGreen)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('$totalJamWajib', 'Jam Wajib', AppTheme.accent)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('$sisaJam', 'Jam Sisa', sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
    ]);
  }

  Widget _statBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _menuItem(IconData icon, String title, {String? subtitle}) {
    return Builder(builder: (ctx) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.accent),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        onTap: () {},
      ),
    ));
  }
}