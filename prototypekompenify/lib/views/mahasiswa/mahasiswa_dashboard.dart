// lib/views/mahasiswa/mahasiswa_dashboard.dart
// Sudah tersambung ke API Laravel menggunakan sistem kontroler baru & StatefulWidget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mahasiswa_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';
import 'kompen_saya.dart';

class MahasiswaDashboard extends StatefulWidget {
  const MahasiswaDashboard({super.key});

  @override
  State<MahasiswaDashboard> createState() => _MahasiswaDashboardState();
}

class _MahasiswaDashboardState extends State<MahasiswaDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 🚀 AMBIL TOKEN SAH DARI AUTH CONTROLLER KELOMPOKMU LORR
        final token = context.read<AuthController>().token ?? '';

        // OPER TOKEN NYA KE SINI BIAR KONTROLER MAHASISWA TIDAK MARAH
        context.read<MahasiswaController>().fetchPengajuanSaya(token);
        context.read<AuthController>().refreshProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mengakses data sesi pengguna dari AuthController
    final authController = context.watch<AuthController>();
    final user = authController.currentUser!;

    // 2. Mengakses data operasional kompen dari MahasiswaController
    final mhsController = context.watch<MahasiswaController>();

    // Mendapatkan data statis rekap melalui data backward compatibility di AuthController
    final rekap = authController.getRekap(user.id.toString());

    // Mengambil riwayat pengajuan mentah dari MahasiswaController
    final allPengajuan = mhsController.pengajuanSaya;

    // 🚀 FILTER SAKTI: Buang status 'diterima' (Selesai/Lunas) agar dashboard bersih jink!
    final pengajuanAktif = allPengajuan
        .where((p) => p.status != 'diterima')
        .toList();
    final recent = pengajuanAktif.take(3).toList();

    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          onRefresh: () async {
            final token = context.read<AuthController>().token ?? '';
            await context.read<AuthController>().refreshProfile();
            await context.read<MahasiswaController>().fetchPengajuanSaya(token);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profil Pengguna
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0] : 'M',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user.name.split(' ').first}! 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: rekap.sudahLunas
                            ? AppTheme.accentGreen.withOpacity(0.15)
                            : AppTheme.accentOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rekap.sudahLunas
                              ? AppTheme.accentGreen.withOpacity(0.3)
                              : AppTheme.accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        rekap.sudahLunas
                            ? '✅ Lunas'
                            : '⏳ ${rekap.sisaJam} jam lagi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: rekap.sudahLunas
                              ? AppTheme.accentGreen
                              : AppTheme.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _RekapCard(
                  rekap: rekap,
                  totalWajib: user.mahasiswa?.totalJamKompen,
                  sisaJam: user.mahasiswa?.sisaJamKompen,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Pengajuan',
                        value: '${allPengajuan.length}',
                        icon: Icons.assignment_outlined,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Selesai (Lunas)',
                        // Tetap menghitung status diterima untuk keperluan statistik counter lorr
                        value:
                            '${allPengajuan.where((p) => p.status == 'diterima').length}',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Kompen Terbaru',
                  action: 'Lihat Semua',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'Belum ada kompen berjalan',
                    subtitle:
                        'Pilih assignment untuk mulai mengajukan kompen lorr!',
                  )
                else
                  ...recent
                      .map(
                        (p) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    KompenDetailScreen(pengajuan: p),
                              ),
                            );
                          },
                          child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.assignmentJudul ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.assignmentJamKompen ?? 0} jam kompen',
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
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p.statusLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: p.statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RekapCard extends StatelessWidget {
  final RekapKompen rekap;
  final int? totalWajib;
  final int? sisaJam;

  const _RekapCard({required this.rekap, this.totalWajib, this.sisaJam});

  @override
  Widget build(BuildContext context) {
    final displayTotalWajib = totalWajib ?? rekap.totalJamWajib;
    final displaySisaJam = sisaJam ?? rekap.sisaJam;
    final displaySelesai = displayTotalWajib - displaySisaJam;

    double pct = displayTotalWajib > 0
        ? (displaySelesai / displayTotalWajib)
        : 0.0;
    pct = pct.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Rekap Jam Kompen',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$displaySelesai Jam',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'sudah diselesaikan',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$displayTotalWajib Jam',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'total wajib',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
