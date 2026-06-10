// lib/views/kaprodi/kaprodi_dashboard.dart
// Menggunakan AuthController untuk kontrol sesi dan KaprodiController untuk pemantauan data pimpinan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kaprodi_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../auth/login_screen.dart';

class KaprodiDashboard extends StatelessWidget {
  const KaprodiDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Mengakses sesi login pengguna aktif dari AuthController
    final authController = context.watch<AuthController>();
    final user = authController.currentUser!;

    // 2. Mengakses kumpulan data real-time meja pimpinan dari KaprodiController
    final kaprodiController = context.watch<KaprodiController>();
    final allPengajuan = kaprodiController.pengajuanMenungguVerifikasiKaprodi;

    // Filter kalkulasi kuantitas data berdasarkan status string database REST API Laravel baru
    final menunggu = allPengajuan
        .where((p) => p.status == 'menunggu_ttd_kaprodi')
        .length;

    final lunas = allPengajuan
        .where((p) => p.status == 'selesai' || p.status == 'diterima')
        .length;

    final ditolak = allPengajuan.where((p) => p.status == 'ditolak').length;

    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          // Sinkronisasi data utama pimpinan menggunakan AuthController
          onRefresh: () => context.read<AuthController>().refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Header Profil & Tombol Keluar Sesi
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
                            'Kaprodi',
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

                // Panel Grid Informasi Statis (StatCard)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      label: 'Menunggu Approval',
                      value: '$menunggu',
                      icon: Icons.pending_actions_rounded,
                      color: AppTheme.accentOrange,
                    ),
                    StatCard(
                      label: 'Total Pengajuan',
                      value: '${allPengajuan.length}',
                      icon: Icons.assignment_rounded,
                      color: AppTheme.accent,
                    ),
                    StatCard(
                      label: 'Sudah Lunas',
                      value: '$lunas',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.accentGreen,
                    ),
                    StatCard(
                      label: 'Ditolak',
                      value: '$ditolak',
                      icon: Icons.cancel_rounded,
                      color: AppTheme.accentRed,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Menunggu Persetujuan Anda'),
                const SizedBox(height: 12),

                // Menampilkan 5 antrean teratas dan mengurai langsung visual kartunya
                ...allPengajuan
                    .where((p) => p.status == 'menunggu_ttd_kaprodi')
                    .take(5)
                    .map(
                      (p) => Container(
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
                                    p.mahasiswaNama ?? 'Mahasiswa',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.assignmentJudul ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Butuh TTD',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (allPengajuan
                    .where((p) => p.status == 'menunggu_ttd_kaprodi')
                    .isEmpty)
                  const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Tidak ada yang menunggu',
                    subtitle: 'Semua pengajuan sudah diproses',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
