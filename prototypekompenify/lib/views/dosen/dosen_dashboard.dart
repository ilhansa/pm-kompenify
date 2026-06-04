import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';
import '../auth/login_screen.dart';

// ─── Dosen Dashboard ─────────────────────────────────────────────────────────
class DosenDashboard extends StatelessWidget {
  const DosenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    // Konversi user.id (int) ke String agar singkron dengan fungsi statis
    final myAssignments = svc.getAssignments(dosenId: user.id.toString());
    final myVerifikasi = svc.getPengajuan(dosenId: user.id.toString());
    final menunggu = myVerifikasi
        .where((p) => p.status == KompenStatus.proses)
        .length;
    final selesai = myVerifikasi
        .where(
          (p) =>
              p.status == KompenStatus.lunas ||
              p.status == KompenStatus.disetujuiDosen,
        )
        .length;

    return GradientBackground(
      child: SafeArea(
        // 📝 1. BUNGKUS DENGAN REFRESH INDICATOR
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          onRefresh: () => context.read<DataService>().refreshDataDosen(),
          child: SingleChildScrollView(
            // 📝 2. WAJIB ADA PHYSICS INI
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        svc.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                ...myAssignments
                    .take(3)
                    .map((a) => AssignmentCard(assignment: a)),
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