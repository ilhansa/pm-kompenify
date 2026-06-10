// lib/views/dosen/dosen_dashboard.dart
// Menggunakan AuthController untuk kontrol sesi dan DosenController untuk monitoring data dosen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dosen_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';

class DosenDashboard extends StatelessWidget {
  const DosenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Mengakses data sesi login pengguna aktif dari AuthController
    final authController = context.watch<AuthController>();
    final user = authController.currentUser!;

    // 2. Mengakses kumpulan data tugas dan verifikasi dari DosenController
    final dosenController = context.watch<DosenController>();

    final myAssignments = dosenController.assignmentsApi;
    final myVerifikasi = dosenController.pengajuanMasuk;

    // Filter kalkulasi jumlah data real-time berdasarkan status string backend Laravel
    final menunggu = myVerifikasi
        .where((p) => p.status == 'pending' || p.status == 'sedang dikerjakan')
        .length;

    final selesai = myVerifikasi
        .where(
          (p) =>
              p.status == 'diterima' ||
              p.status == 'menunggu_ttd_dosen' ||
              p.status == 'menunggu_ttd_kaprodi',
        )
        .length;

    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          // Sinkronisasi pembaruan profil terpusat menggunakan AuthController
          onRefresh: () => context.read<AuthController>().refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Header & Tombol Logout Sesi
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user.name.split(' ').first}! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Dosen',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppTheme.accentRed,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        // Menjalankan fungsi reset sesi total di AuthController
                        context.read<AuthController>().logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Panel Grid Informasi Ringkasan (StatCard)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      label: 'Assignment Dibuat',
                      value: '${myAssignments.length}',
                      icon: Icons.assignment_rounded,
                      color: AppTheme.accent,
                    ),
                    StatCard(
                      label: 'Menunggu Verifikasi',
                      value: '$menunggu',
                      icon: Icons.pending_actions_rounded,
                      color: AppTheme.accentOrange,
                    ),
                    StatCard(
                      label: 'Total Pengajuan',
                      value: '${myVerifikasi.length}',
                      icon: Icons.people_rounded,
                      color: AppTheme.primaryLight,
                    ),
                    StatCard(
                      label: 'Sudah Diverifikasi',
                      value: '$selesai',
                      icon: Icons.verified_rounded,
                      color: AppTheme.accentGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Assignment Terbaru',
                  action: 'Kelola',
                  onAction: () {},
                ),
                const SizedBox(height: 12),

                // Mengurai langsung susunan kartu penugasan
                ...myAssignments
                    .take(3)
                    .map(
                      (a) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${a.jamKompen} jam kompen',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: a.status == 'aktif'
                                    ? AppTheme.accentGreen.withOpacity(0.15)
                                    : AppTheme.textMuted.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: a.status == 'aktif'
                                      ? AppTheme.accentGreen
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (myAssignments.isEmpty)
                  const EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'Belum ada assignment',
                    subtitle: 'Buat assignment di tab Assignment',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
