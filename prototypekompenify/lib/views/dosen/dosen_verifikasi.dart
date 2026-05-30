import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

// ─── Dosen Verifikasi ─────────────────────────────────────────────────────────
class DosenVerifikasi extends StatelessWidget {
  const DosenVerifikasi({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    // Konversi user.id ke String
    final list = svc
        .getPengajuan(dosenId: user.id.toString())
        .where(
          (p) =>
              p.status == KompenStatus.proses ||
              p.status == KompenStatus.menunggu,
        )
        .toList();
    final history = svc
        .getPengajuan(dosenId: user.id.toString())
        .where(
          (p) =>
              p.status != KompenStatus.proses &&
              p.status != KompenStatus.menunggu,
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
                    'Verifikasi Kompen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${list.length} menunggu verifikasi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 📝 GANTI BAGIAN EXPANDED-NYA DENGAN INI
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                onRefresh: () => context.read<DataService>().refreshDataDosen(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Tidak ada yang perlu diverifikasi',
                        ),
                      )
                    else ...[
                      ...list.map((p) => _VerifikasiCard(pengajuan: p)),
                    ],
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...history.map((p) => KompenCard(pengajuan: p)),
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

class _VerifikasiCard extends StatelessWidget {
  final PengajuanKompen pengajuan;
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
                  p.mahasiswaNama,
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
            p.mahasiswaNim,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.assignment_outlined,
            label: 'Assignment',
            value: p.assignmentJudul,
          ),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Jam',
            value: '${p.jamKompen} jam',
          ),
          if (p.buktiFotoPath != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    color: AppTheme.accentGreen,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Bukti sudah diupload',
                    style: TextStyle(color: AppTheme.accentGreen, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    color: AppTheme.accentOrange,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Menunggu mahasiswa upload bukti',
                    style: TextStyle(
                      color: AppTheme.accentOrange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (p.buktiFotoPath != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(context, p),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppTheme.accentRed,
                    ),
                    label: const Text(
                      'Minta Revisi',
                      style: TextStyle(color: AppTheme.accentRed, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(context, p),
                    icon: const Icon(Icons.draw_outlined, size: 16),
                    label: const Text(
                      'Berikan E-TTD',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _approve(BuildContext context, PengajuanKompen p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Row(
          children: [
            Icon(Icons.draw_outlined, color: AppTheme.accentGreen),
            SizedBox(width: 8),
            Text('Berikan E-TTD'),
          ],
        ),
        content: Text(
          'Setujui dan tandatangani kompen ${p.mahasiswaNama} untuk "${p.assignmentJudul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataService>().verifikasiDosen(p.id, true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✅ E-TTD berhasil diberikan! Notifikasi dikirim ke Kaprodi.',
                  ),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('Setujui & TTD'),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, PengajuanKompen p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Minta Revisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Berikan catatan untuk mahasiswa:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan catatan revisi...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataService>().verifikasiDosen(
                p.id,
                false,
                catatan: ctrl.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '📝 Revisi diminta. Notifikasi dikirim ke mahasiswa.',
                  ),
                  backgroundColor: AppTheme.accentOrange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
            ),
            child: const Text('Kirim Revisi'),
          ),
        ],
      ),
    );
  }
}
