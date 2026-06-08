// lib/views/kaprodi/kaprodi_verifikasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/data_service.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class KaprodiVerifikasi extends StatefulWidget {
  const KaprodiVerifikasi({super.key});

  @override
  State<KaprodiVerifikasi> createState() => _KaprodiVerifikasiState();
}

class _KaprodiVerifikasiState extends State<KaprodiVerifikasi> {
  @override
  void initState() {
    super.initState();
    // Tarik data pengajuan masuk khusus untuk role Kaprodi saat ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().fetchPengajuanMenungguVerifikasiKaprodi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    // 🚀 FILTER DOSEN (KAPRODI SEBAGAI DOSEN):
    // Hanya menampilkan data yang statusnya 'pending' alias baru mendaftar/war slot di tugas miliknya Kaprodi
    final list = svc.pengajuanMenungguVerifikasiKaprodi
        .where((p) => p.status == 'pending')
        .toList();

    // Riwayat verifikasi awal miliknya
    final history = svc.pengajuanMenungguVerifikasiKaprodi
        .where(
          (p) => p.status != 'pending' && p.status != 'menunggu_ttd_kaprodi',
        )
        .toList();

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verifikasi Kompen (Sebagai Dosen)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${list.length} pengajuan tugas Anda memerlukan verifikasi',
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
                onRefresh: () =>
                    context.read<DataService>().refreshDataKaprodi(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Tidak ada pengajuan yang perlu diverifikasi',
                        ),
                      )
                    else
                      ...list.map((p) => _VerifikasiCard(pengajuan: p)),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Riwayat Verifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...history.map((p) => _RiwayatCard(pengajuan: p)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGET CARD VERIFIKASI AWAL ───
class _VerifikasiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _VerifikasiCard({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentOrange.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.mahasiswaNama ?? 'Mahasiswa',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              StatusBadge(label: p.statusLabel, color: p.statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            p.mahasiswaNim ?? '-',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.assignment_outlined,
            label: 'Assignment',
            value: p.assignmentJudul ?? '-',
          ),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Jam',
            value: '${p.assignmentJamKompen ?? 0} jam',
          ),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Diajukan',
            value: timeago.format(
              DateTime.tryParse(p.createdAt) ?? DateTime.now(),
              locale: 'id',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showDialogAksi(context, p, 'ditolak', 'Menolak'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accentRed),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(color: AppTheme.accentRed),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDialogAksi(
                    context,
                    p,
                    'menunggu_ttd_dosen',
                    'Menerima',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                  ),
                  child: const Text('Terima & Plot TTD'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialogAksi(
    BuildContext context,
    PengajuanModel p,
    String statusTarget,
    String label,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('$label Pengajuan'),
        content: Text(
          'Apakah Anda yakin ingin memproses pengajuan dari ${p.mahasiswaNama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await context
                  .read<DataService>()
                  .updateStatusPengajuan(p.id, statusTarget);
              if (context.mounted) {
                context
                    .read<DataService>()
                    .fetchPengajuanMenungguVerifikasiKaprodi();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✓ Sukses diproses!'
                          : '❌ Gagal',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _RiwayatCard({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.assignmentJudul ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(label: p.statusLabel, color: p.statusColor),
        ],
      ),
    );
  }
}
