import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';
import '../../models/models.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser;

    if (user == null) return const SizedBox();

    final userIdStr = user.id.toString();
    
    // Deteksi Role secara dinamis dari Enum model
    final roleName = user.role.name.toLowerCase();
    final isMahasiswa = roleName == 'mhs' || roleName == 'mahasiswa';
    final isDosenOrKaprodi = roleName == 'dosen' || roleName == 'kaprodi';

    // Ambil data untuk Mahasiswa
    final rekap = svc.getRekap(userIdStr);

    // Ambil data statistik riwayat untuk Dosen
    final totalAssignment = svc.getAssignments(dosenId: userIdStr).length;
    final totalVerifikasi = svc.getPengajuan(dosenId: userIdStr)
        .where((p) => p.status == KompenStatus.proses)
        .length;

    return GradientBackground(
      child: SafeArea(
        // 📝 1. BUNGKUS DENGAN REFRESH INDICATOR DI SINI
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          // 📝 2. PANGGIL FUNGSI REFRESH SAKTI DARI CONTROLLER
          onRefresh: () => context.read<DataService>().refreshDataMahasiswa(),
          child: SingleChildScrollView(
            // 📝 3. WAJIB DIKASIH PHYSICS INI BIAR LAYAR BISA DITARIK KE BAWAH
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // ─── AVATAR USER ───
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // NAMES & BADGE ROLE
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: user.role.name.toUpperCase(),
                  color: isMahasiswa ? AppTheme.accent : AppTheme.accentGreen,
                ),
                const SizedBox(height: 8),
                
                // IDENTITAS (NIM / NIP)
                Text(
                  isMahasiswa ? 'NIM: ${user.username}' : 'NIP: ${user.username}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                
                // PROGRAM STUDI KONDISIONAL
                if (isMahasiswa && user.mahasiswa?.prodi != null)
                  Text(user.mahasiswa!.prodi!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))
                else if (isDosenOrKaprodi && user.dosen?.prodi != null)
                  Text(user.dosen!.prodi!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),

                const SizedBox(height: 28),

                // ─── KARTU STATISTIK KONDISIONAL BERDASARKAN ROLE ───
                if (isMahasiswa) ...[
                  _buildMahasiswaRekap(rekap),
                ] else if (isDosenOrKaprodi) ...[
                  _buildDosenRekap(totalAssignment, totalVerifikasi),
                  const SizedBox(height: 14),
                  _buildSignatureCard(user.dosen?.signature_base64),
                ],

                const SizedBox(height: 24),

                // ─── MENU UTAMA LIST VIEW KONDISIONAL ───
                if (isMahasiswa) ...[
                  _menuItem(Icons.assignment_outlined, 'Riwayat Kompen Saya',
                      subtitle: '${svc.getPengajuan(mahasiswaId: userIdStr).length} pengajuan'),
                ] else if (isDosenOrKaprodi) ...[
                  _menuItem(Icons.assignment_turned_in_outlined, 'Daftar Assignment Saya',
                      subtitle: '$totalAssignment tugas aktif di sistem'),
                  _menuItem(Icons.pending_actions_rounded, 'Menunggu Verifikasi',
                      subtitle: '$totalVerifikasi berkas kompen masuk'),
                ],

                _menuItem(Icons.notifications_outlined, 'Notifikasi',
                    subtitle: '${svc.getUnreadCount(userIdStr)} belum dibaca'),
                _menuItem(Icons.help_outline_rounded, 'Bantuan & FAQ Sistem'),
                _menuItem(Icons.info_outline_rounded, 'Tentang Kompenify V1.0'),
                
                const SizedBox(height: 20),
                
                // BUTTON LOGOUT SAKTI
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    onTap: () {
                      svc.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    leading: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
                    title: const Text(
                      'Keluar dari Aplikasi',
                      style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Row Statistik Khusus Mahasiswa
  Widget _buildMahasiswaRekap(dynamic rekap) {
    final displayTotalWajib = rekap.totalJamWajib;
    final displaySisaJam = rekap.sisaJam;
    final displaySelesai = displayTotalWajib - displaySisaJam;
    final sudahLunas = displaySisaJam <= 0;

    return Row(
      children: [
        Expanded(child: _statBox('$displaySelesai', 'Jam Selesai', AppTheme.accentGreen)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('$displayTotalWajib', 'Jam Wajib', AppTheme.accent)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('$displaySisaJam', 'Jam Sisa', sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
      ],
    );
  }

  // Row Statistik Khusus Dosen
  Widget _buildDosenRekap(int assignmentCount, int pendingVerification) {
    return Row(
      children: [
        Expanded(child: _statBox('$assignmentCount', 'Tugas Dibuat', AppTheme.accent)),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            '$pendingVerification', 
            'Butuh E-TTD', 
            pendingVerification > 0 ? AppTheme.accentOrange : AppTheme.accentGreen
          )
        ),
      ],
    );
  }

  // Indikator Spesimen E-TTD Digital Khusus Dosen
  Widget _buildSignatureCard(String? base64Signature) {
    final hasSignature = base64Signature != null && base64Signature.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(
            hasSignature ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
            color: hasSignature ? AppTheme.accentGreen : AppTheme.accentOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spesimen E-TTD Digital',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  hasSignature 
                      ? 'Status: Siap Menandatangani Kompen' 
                      : 'Belum terupload. Hubungi Admin Jurusan.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            hasSignature ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: hasSignature ? AppTheme.accentGreen : AppTheme.accentOrange,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {String? subtitle}) {
    return Builder(
      builder: (ctx) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.accent),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)) : null,
          trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          onTap: () {},
        ),
      ),
    );
  }
}