import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    final rekap = svc.getRekap(user.id);

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
              child: Center(child: Text(user.nama[0], style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 16),
            Text(user.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            StatusBadge(label: user.roleLabel, color: AppTheme.accent),
            const SizedBox(height: 4),
            Text(user.nim, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            if (user.prodi != null) Text(user.prodi!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),

            const SizedBox(height: 28),
            // Rekap stat
            _RekapRow(rekap: rekap),
            const SizedBox(height: 24),

            // Menu list
            _menuItem(Icons.assignment_outlined, 'Riwayat Kompen', subtitle: '${svc.getPengajuan(mahasiswaId: user.id).length} pengajuan'),
            _menuItem(Icons.notifications_outlined, 'Notifikasi', subtitle: '${svc.getUnreadCount(user.id)} belum dibaca'),
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

  Widget _RekapRow({required dynamic rekap}) {
    return Row(children: [
      Expanded(child: _statBox('${rekap.totalJamSelesai}', 'Jam Selesai', AppTheme.accentGreen)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('${rekap.totalJamWajib}', 'Jam Wajib', AppTheme.accent)),
      const SizedBox(width: 10),
      Expanded(child: _statBox('${rekap.sisaJam}', 'Jam Sisa', rekap.sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
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