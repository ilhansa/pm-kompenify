import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/data_service.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class HalamanTtdDigital extends StatefulWidget {
  const HalamanTtdDigital({super.key});

  @override
  State<HalamanTtdDigital> createState() => _HalamanTtdDigitalState();
}

class _HalamanTtdDigitalState extends State<HalamanTtdDigital> {
  @override
  void initState() {
    super.initState();
    // Tarik data antrean verifikasi terupdate secara realtime saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().fetchPengajuanMenungguVerifikasi();
    });
  }

  void _prosesTandaTanganDosen(
    BuildContext context,
    String id,
    String mahasiswaNama,
    String tokenAktif,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.draw_rounded, color: AppTheme.accentGreen),
            SizedBox(width: 10),
            Text(
              'Sahkan Dokumen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membubuhkan E-TTD pada berkas kompen milik $mahasiswaNama? Tindakan ini akan dicatat ke tabel verifikasi database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            onPressed: () async {
              Navigator.pop(context);

              // ⚡ Nembak fungsi parameter aman kita di DataService
              final result = await context
                  .read<DataService>()
                  .generateTandaTanganDigitalDosen(id, tokenAktif);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✅ ${result['message']}'
                          : '❌ Gagal: ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                // Auto refresh list data global agar kartunya hilang pindah ke meja Kaprodi
                if (result['success'] == true) {
                  context
                      .read<DataService>()
                      .fetchPengajuanMenungguVerifikasi();
                }
              }
            },
            child: const Text(
              'Tanda Tangani',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    // 🚀 FILTER VERSI SARAN ABANG: Murni menyaring berkas yang nunggu TTD Dosen
    final antreanDosen = svc.pengajuanMenungguVerifikasi
        .where((p) => p.status == 'menunggu_ttd_dosen')
        .toList();

    return GradientBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meja E-Tanda Tangan Dosen',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${antreanDosen.length} dokumen mahasiswa mengantre tanda tangan Anda',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                onRefresh: () => context
                    .read<DataService>()
                    .fetchPengajuanMenungguVerifikasi(),
                child: antreanDosen.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 160),
                            child: EmptyState(
                              icon: Icons.draw_rounded,
                              title: 'Meja TTD Bersih, Pak/Bu Dosen!',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: antreanDosen.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = antreanDosen[index];
                          return _CardTtdDosenPremium(
                            pengajuan: p,
                            onPencetTTD: () => _prosesTandaTanganDosen(
                              context,
                              p.id,
                              p.mahasiswaNama ?? 'Mahasiswa',
                              svc.token ??
                                  '', // Pasok token login aktif secara aman ke parameter
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ✨ DESIGN CARD PREMIUM VERSI ABANG ✨ ───────────────────────────────────
class _CardTtdDosenPremium extends StatelessWidget {
  final PengajuanModel pengajuan;
  final VoidCallback onPencetTTD;

  const _CardTtdDosenPremium({
    required this.pengajuan,
    required this.onPencetTTD,
  });

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    final nama = p.mahasiswaNama ?? 'Mahasiswa';
    final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        p.mahasiswaNim ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
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
                    color: const Color(0xFFFFB020).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Siap TTD',
                    style: TextStyle(
                      color: Color(0xFFFFB020),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            InfoRow(
              icon: Icons.assignment_outlined,
              label: 'Assignment',
              value: p.assignmentJudul ?? '-',
            ),
            InfoRow(
              icon: Icons.schedule_outlined,
              label: 'Total Waktu',
              value: '${p.assignmentJamKompen ?? 0} jam kompen',
            ),
            InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Masuk Antrean',
              value: timeago.format(
                DateTime.tryParse(p.createdAt) ?? DateTime.now(),
                locale: 'id',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPencetTTD,
                icon: const Icon(
                  Icons.draw_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Bubuhkan E-TTD Dosen Sekarang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF8D), // Hijau Sukses
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }
}
