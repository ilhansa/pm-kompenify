// lib/views/shared/profil_screen.dart
// Menghubungkan AuthController pusat serta Controller spesifik role untuk merender rekap statistik profil dinamis

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mahasiswa_controller.dart';
import '../../controllers/dosen_controller.dart';
import '../../controllers/kaprodi_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatelessWidget {
  // 🚀 CALLBACK NAVIGASI TAB SHELL UTAMA LORR
  final Function(int)? onNavigateToTab;

  const ProfilScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil session user terpusat dari AuthController
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    if (user == null) return const SizedBox();

    // 📝 DETEKSI ROLE SECARA SPESIFIK
    final roleName = user.role.name.toLowerCase();
    final isMahasiswa = roleName == 'mhs' || roleName == 'mahasiswa';
    final isDosen = roleName == 'dosen';
    final isKaprodi = roleName == 'kaprodi';

    // 📝 KONTROLER KHUSUS ROLE UNTUK MENGAMBIL DATA API
    final mhsController = context.watch<MahasiswaController>();
    final dosenController = context.watch<DosenController>();
    final kaprodiController = context.watch<KaprodiController>();

    // ─── AMBIL DATA SESUAI MODEL ASLI TIM SULTAN ───

    // -- Data Mahasiswa
    final listPengajuanMhs = isMahasiswa ? mhsController.pengajuanSaya : [];
    final totalPengajuanMhs = listPengajuanMhs.length;
    final displayTotalWajib = user.mahasiswa?.totalJamKompen ?? 0;
    final displaySisaJam = user.mahasiswa?.sisaJamKompen ?? 0;

    // -- Data Dosen (Diambil dinamis berdasarkan status pengerjaan lorr!)
    final totalAssignment = isDosen ? dosenController.assignmentsApi.length : 0;
    final totalVerifikasi = isDosen
        ? dosenController.pengajuanMenungguVerifikasi
              .where((p) => p.status == 'sedang dikerjakan')
              .length
        : 0;

    // -- Data Kaprodi
    final allPengajuanKaprodi =
        kaprodiController.pengajuanMenungguVerifikasiKaprodi;
    final kaprodiPending = isKaprodi
        ? allPengajuanKaprodi
              .where(
                (p) =>
                    p.status.toString().toLowerCase().trim() ==
                    'menunggu_ttd_kaprodi',
              )
              .length
        : 0;
    final kaprodiLunas = isKaprodi
        ? allPengajuanKaprodi
              .where(
                (p) =>
                    p.status.toString().toLowerCase().trim() == 'selesai' ||
                    p.status.toString().toLowerCase().trim() == 'diterima',
              )
              .length
        : 0;

    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          // 📝 REFRESH SELEKTIF DATA SERVER LARAGON LORR
          onRefresh: () async {
            await context.read<AuthController>().refreshProfile();

            final token = authController.token ?? '';
            if (token.isNotEmpty) {
              if (isMahasiswa) {
                await context.read<MahasiswaController>().fetchPengajuanSaya(
                  token,
                );
              } else if (isDosen) {
                await context.read<DosenController>().fetchAssignments(token);
              } else if (isKaprodi) {
                await context
                    .read<KaprodiController>()
                    .fetchPengajuanMenungguVerifikasiKaprodi(token);
              }
            }
          },
          child: SingleChildScrollView(
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
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: user.role.name.toUpperCase(),
                  color: isMahasiswa
                      ? AppTheme.accent
                      : (isKaprodi ? AppTheme.primary : AppTheme.accentGreen),
                ),
                const SizedBox(height: 8),

                // IDENTITAS UTAMA (NIM / NIP)
                Text(
                  isMahasiswa
                      ? 'NIM: ${user.username}'
                      : 'NIP: ${user.username}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),

                // PRODI KONDISIONAL (HANYA UNTUK MAHASISWA, DOSEN/KAPRODI SUDAH DIHAPUS TOTAL)
                if (isMahasiswa && user.mahasiswa?.prodi != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.mahasiswa!.prodi!,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ─── KARTU STATISTIK RINGKASAN DATA ───
                if (isMahasiswa) ...[
                  _buildMahasiswaRekap(displayTotalWajib, displaySisaJam),
                ] else if (isDosen) ...[
                  _buildDosenRekap(totalAssignment, totalVerifikasi),
                  const SizedBox(height: 14),
                  _buildSignatureCard(user.dosen?.signature_base64),
                ] else if (isKaprodi) ...[
                  _buildKaprodiRekap(kaprodiPending, kaprodiLunas),
                  const SizedBox(height: 14),
                  _buildSignatureCard(null),
                ],

                const SizedBox(height: 24),

                // ─── MENU OPSI LIST VIEW NAVIGASI TAB LORR ───
                if (isMahasiswa) ...[
                  _menuItem(
                    Icons.assignment_outlined,
                    'Riwayat Kompen Saya',
                    subtitle: '$totalPengajuanMhs pengajuan tercatat',
                    onTap: () {
                      if (onNavigateToTab != null) onNavigateToTab!(2);
                    },
                  ),
                  _menuItem(
                    Icons.assignment_ind_outlined,
                    'Daftar Assignment Aktif',
                    subtitle: 'Lihat tugas kompen dari dosen',
                    onTap: () {
                      if (onNavigateToTab != null) onNavigateToTab!(1);
                    },
                  ),
                ] else if (isDosen) ...[
                  _menuItem(
                    Icons.assignment_turned_in_outlined,
                    'Daftar Assignment Saya',
                    subtitle: '$totalAssignment tugas aktif di sistem',
                    onTap: () {
                      if (onNavigateToTab != null) onNavigateToTab!(1);
                    },
                  ),
                  _menuItem(
                    Icons.pending_actions_rounded,
                    'Menunggu Verifikasi',
                    subtitle: '$totalVerifikasi berkas kompen masuk',
                    onTap: () {
                      if (onNavigateToTab != null) onNavigateToTab!(2);
                    },
                  ),
                ] else if (isKaprodi) ...[
                  _menuItem(
                    Icons.verified_outlined,
                    'Approval Akhir Kompen (E-TTD)',
                    subtitle: '$kaprodiPending berkas mengantre persetujuan',
                    onTap: () {
                      if (onNavigateToTab != null) onNavigateToTab!(2);
                    },
                  ),
                ],

                _menuItem(
                  Icons.notifications_outlined,
                  'Notifikasi Sistem',
                  subtitle:
                      '${authController.unreadCount} pemberitahuan belum dibaca',
                  onTap: () {
                    if (onNavigateToTab != null) onNavigateToTab!(3);
                  },
                ),

                _menuItem(
                  Icons.info_outline_rounded,
                  'Tentang Kompenify V1.0',
                  subtitle: 'Informasi sistem dan aplikasi mobile',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.bgCard,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppTheme.accent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Tentang Kompenify',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Kompenify adalah aplikasi mobile pencatatan dan elektronisasi kompensasi mahasiswa yang terintegrasi langsung dengan sistem utama kampus lorr.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Versi Aplikasi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      'v1.0.0 (Production-Ready)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pengembang',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      'Tim PBL Kelompok 4',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Tutup',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ─── BUTTON LOGOUT SAKTI ───
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accentRed.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      context.read<AuthController>().logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppTheme.accentRed,
                    ),
                    title: const Text(
                      'Keluar dari Aplikasi',
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontWeight: FontWeight.w600,
                      ),
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

  // --- Widget Bantuan Dinamis Kelompok Sultan ---

  Widget _buildMahasiswaRekap(int totalWajib, int sisaJam) {
    final displaySelesai = (totalWajib - sisaJam) < 0
        ? totalWajib
        : (totalWajib - sisaJam);
    final sudahLunas = sisaJam <= 0;

    return Row(
      children: [
        Expanded(
          child: _statBox(
            '$displaySelesai',
            'Jam Selesai',
            AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _statBox('$totalWajib', 'Jam Wajib', AppTheme.accent)),
        const SizedBox(width: 10),
        Expanded(
          child: _statBox(
            '$sisaJam',
            'Jam Sisa',
            sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildDosenRekap(int assignmentCount, int pendingVerification) {
    return Row(
      children: [
        Expanded(
          child: _statBox('$assignmentCount', 'Tugas Dibuat', AppTheme.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            '$pendingVerification',
            'Butuh E-TTD',
            pendingVerification > 0
                ? AppTheme.accentOrange
                : AppTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildKaprodiRekap(int pendingCount, int lunasCount) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            '$pendingCount',
            'Perlu Approval',
            pendingCount > 0 ? AppTheme.accentOrange : AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox('$lunasCount', 'Selesai & Lunas', AppTheme.accent),
        ),
      ],
    );
  }

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
            hasSignature
                ? Icons.verified_user_rounded
                : Icons.gpp_maybe_rounded,
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasSignature
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
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
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
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
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
