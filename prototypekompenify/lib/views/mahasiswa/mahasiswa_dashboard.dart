import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

class MahasiswaDashboard extends StatelessWidget {
  const MahasiswaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    
    // 1. Tambahkan .toString() karena fungsi statis meminta parameter String
    final rekap = svc.getRekap(user.id.toString());
    final pengajuan = svc.getPengajuan(mahasiswaId: user.id.toString());
    final recent = pengajuan.take(3).toList();

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                // Ganti .nama menjadi .name sesuai UserModel REST API Laravel
                child: Center(child: Text(user.name.isNotEmpty ? user.name[0] : 'M', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Ganti .nama menjadi .name
                Text('Halo, ${user.name.split(' ').first}! 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                // Ganti .nim menjadi .username
                Text(user.username, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: rekap.sudahLunas ? AppTheme.accentGreen.withOpacity(0.15) : AppTheme.accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rekap.sudahLunas ? AppTheme.accentGreen.withOpacity(0.3) : AppTheme.accentOrange.withOpacity(0.3)),
                ),
                child: Text(rekap.sudahLunas ? '✅ Lunas' : '⏳ ${rekap.sisaJam} jam lagi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: rekap.sudahLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
              ),
            ]),
            const SizedBox(height: 24),

            // Rekap Card (Menampilkan data gabungan statis & dinamis Laravel)
            _RekapCard(rekap: rekap, totalWajib: user.mahasiswa?.totalJamKompen, sisaJam: user.mahasiswa?.sisaJamKompen),
            const SizedBox(height: 24),

            // Quick Stats
            Row(children: [
              Expanded(child: StatCard(
                label: 'Total Pengajuan',
                value: '${pengajuan.length}',
                icon: Icons.assignment_outlined,
                color: AppTheme.accent,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatCard(
                label: 'Selesai (Lunas)',
                value: '${pengajuan.where((p) => p.status == KompenStatus.lunas).length}',
                icon: Icons.check_circle_outline,
                color: AppTheme.accentGreen,
              )),
            ]),
            const SizedBox(height: 24),

            // Recent kompen
            SectionHeader(title: 'Kompen Terbaru', action: 'Lihat Semua', onAction: () {}),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const EmptyState(icon: Icons.assignment_outlined, title: 'Belum ada kompen', subtitle: 'Pilih assignment untuk mulai mengajukan kompen')
            else
              ...recent.map((p) => KompenCard(pengajuan: p)),
          ]),
        ),
      ),
    );
  }
}

class _RekapCard extends StatelessWidget {
  final RekapKompen rekap;
  final int? totalWajib;
  final int? sisaJam;

  const _RekapCard({
    required this.rekap,
    this.totalWajib,
    this.sisaJam,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil sisa dan total jam dari Laravel jika tersedia, jika null pakai data fallback rekap statis
    final displayTotalWajib = totalWajib ?? rekap.totalJamWajib;
    final displaySisaJam = sisaJam ?? rekap.sisaJam;
    final displaySelesai = displayTotalWajib - displaySisaJam;
    
    // Hitung persentase progress
    double pct = displayTotalWajib > 0 ? (displaySelesai / displayTotalWajib) : 0.0;
    pct = pct.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Text('Rekap Jam Kompen', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text('${(pct * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ]),
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
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$displaySelesai Jam', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const Text('sudah diselesaikan', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$displayTotalWajib Jam', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
            const Text('total wajib', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ]),
      ]),
    );
  }
}