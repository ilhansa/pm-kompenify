import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';
import '../../models/user_model.dart'; // Import UserModel baru

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser;
    
    if (user == null) return const SizedBox();
    
    // Konversi user.id ke String untuk sinkronisasi ke data statis cadangan
    final userIdStr = user.id.toString();
    final rekap = svc.getRekap(userIdStr);
    final isMahasiswa = user.role == UserRole.mahasiswa;

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)]),
              // Ganti .nama menjadi .name
              child: Center(child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 16),
            // Ganti .nama menjadi .name
            Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            // Mengubah nama enum role menjadi huruf kapital depannya untuk label
            StatusBadge(label: user.role.name.toUpperCase(), color: AppTheme.accent),
            const SizedBox(height: 4),
            // Ganti .nim menjadi .username
            Text(user.username, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            if (isMahasiswa && user.mahasiswa?.prodi != null) 
              Text(user.mahasiswa!.prodi!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),

            const SizedBox(height: 28),
            // Rekap stat -> HANYA DIPERLIHATKAN JIKA USER ADALAH MAHASISWA
            if (isMahasiswa) ...[
              _RekapRow(rekap: rekap, totalWajib: user.mahasiswa?.totalJamKompen, sisaJam: user.mahasiswa?.sisaJamKompen),
              const SizedBox(height: 24),
            ],

            // Menu list
            if (isMahasiswa)
              _menuItem(Icons.assignment_outlined, 'Riwayat Kompen', subtitle: '${svc.getPengajuan(mahasiswaId: userIdStr).length} pengajuan')
            else
              _menuItem(Icons.assignment_outlined, 'Tugas Ditangani', subtitle: '${svc.getAssignments(dosenId: userIdStr).length} dibuat'),
              
            _menuItem(Icons.notifications_outlined, 'Notifikasi', subtitle: '${svc.getUnreadCount(userIdStr)} belum dibaca'),
            _menuItem(Icons.help_outline_rounded, 'Bantuan & FAQ'),
            _menuItem(Icons.info_outline_rounded, 'Tentang Aplikasi'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
              ),
              child: ListTile(
                onTap: () {
                  svc.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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

  Widget _RekapRow({required dynamic rekap, int? totalWajib, int? sisaJam}) {
    // Ambil data asli dari database Laravel jika ada, kalau null pakai data fallback statis
    final displayTotalWajib = totalWajib ?? rekap.totalJamWajib;
    final displaySisaJam = sisaJam ?? rekap.sisaJam;
    final displaySelesai = displayTotalWajib - displaySisaJam;
    final sudahLunas = displaySisaJam <= 0;

    return Row(children: [
      Expanded(child: _statBox('$displaySelesai', 'Jam Selesai', AppTheme.accentGreen)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('$displayTotalWajib', 'Jam Wajib', AppTheme.accent)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('$displaySisaJam', 'Jam Sisa', sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
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