import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';
import '../auth/login_screen.dart';

// ─── Kaprodi Dashboard ────────────────────────────────────────────────────────
class KaprodiDashboard extends StatelessWidget {
  const KaprodiDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    
    final allPengajuan = svc.getPengajuan();
    final menunggu = allPengajuan.where((p) => p.status == KompenStatus.disetujuiDosen).length;
    final lunas = allPengajuan.where((p) => p.status == KompenStatus.lunas).length;
    final ditolak = allPengajuan.where((p) => p.status == KompenStatus.ditolak).length;

    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgCard,
          onRefresh: () => context.read<DataService>().refreshDataKaprodi(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Halo, ${user.name.split(' ').first}! 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Text('Kaprodi', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
                IconButton(
                  icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed, size: 20)),
                  onPressed: () { 
                    svc.logout(); 
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); 
                  },
                ),
              ]),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                children: [
                  StatCard(label: 'Menunggu Approval', value: '$menunggu', icon: Icons.pending_actions_rounded, color: AppTheme.accentOrange),
                  StatCard(label: 'Total Pengajuan', value: '${allPengajuan.length}', icon: Icons.assignment_rounded, color: AppTheme.accent),
                  StatCard(label: 'Sudah Lunas', value: '$lunas', icon: Icons.check_circle_rounded, color: AppTheme.accentGreen),
                  StatCard(label: 'Ditolak', value: '$ditolak', icon: Icons.cancel_rounded, color: AppTheme.accentRed),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Menunggu Persetujuan Anda'),
              const SizedBox(height: 12),
              ...allPengajuan
                .where((p) => p.status == KompenStatus.disetujuiDosen)
                .take(5)
                .map((p) => KompenCard(pengajuan: p)),
              if (allPengajuan.where((p) => p.status == KompenStatus.disetujuiDosen).isEmpty)
                const EmptyState(icon: Icons.inbox_outlined, title: 'Tidak ada yang menunggu', subtitle: 'Semua pengajuan sudah diproses'),
            ]),
          ),
        ),
      ),
    );
  }
}