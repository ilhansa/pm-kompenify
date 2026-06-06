// lib/views/dosen/dosen_verifikasi.dart
// ✅ Sudah tersambung ke API Laravel
// Perubahan dari versi lama:
//   - Data pengajuan dari svc.pengajuanMasuk (API real, bukan statis)
//   - Tombol "Berikan E-TTD" → svc.updateStatusPengajuan(id, 'diterima')
//   - Tombol "Minta Revisi"  → svc.updateStatusPengajuan(id, 'ditolak')
//   - Status dari API: 'pending', 'diterima', 'ditolak'

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/data_service.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class DosenVerifikasi extends StatefulWidget {
  const DosenVerifikasi({super.key});

  @override
  State<DosenVerifikasi> createState() => _DosenVerifikasiState();
}

class _DosenVerifikasiState extends State<DosenVerifikasi> {
  @override
  void initState() {
    super.initState();
    // GET | Otomatis panggil API menunggu verifikasi saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().fetchPengajuanMenungguVerifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    // Memfilter data status pending (menunggu verifikasi)
    final list = svc.pengajuanMenungguVerifikasi
        .where((p) => p.statusLabel == 'Menunggu Verifikasi')
        .toList();

    final history = svc.pengajuanMenungguVerifikasi
        .where((p) => p.statusLabel != 'Menunggu Verifikasi')
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
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                // Menggunakan fungsi refresh bawaan yang sudah kita update
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
                    else
                      ...list.map((p) => _VerifikasiCard(pengajuan: p)),
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

// ─── Card pengajuan pending (bisa terima/tolak) ───────────────────────────────
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

          // 🚀 TAMPILAN FOTO BUKTI / E-TTD MAHASISWA
          if (p.buktiFotos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // Memunculkan pop-up galeri foto saat tombol diklik
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.bgCard,
                      title: const Text('Bukti Pengerjaan Kompen'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: p.buktiFotos.length,
                          itemBuilder: (context, idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.network(
                              p.buktiFotos[idx],
                              fit: BoxFit.contain,
                              headers: const {
                                'ngrok-skip-browser-warning': 'true',
                              },
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.image_search_outlined,
                  size: 18,
                  color: AppTheme.primary,
                ),
                label: Text(
                  'Lihat Bukti Foto (${p.buktiFotos.length})',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTolakDialog(context, p),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppTheme.accentRed,
                  ),
                  label: const Text(
                    'Tolak',
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
                  onPressed: () => _showTerimaDialog(context, p),
                  icon: const Icon(Icons.draw_outlined, size: 16),
                  label: const Text('Terima', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showTerimaDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Row(
        children: [
          Icon(Icons.draw_outlined, color: AppTheme.accentGreen),
          SizedBox(width: 8),
          Text('Terima Pengajuan'),
        ],
      ),
      content: Text(
        'Terima kompen ${p.mahasiswaNama ?? "mahasiswa"} untuk "${p.assignmentJudul ?? "-"}"?\n\nMahasiswa lain yang pending akan otomatis ditolak.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // ✅ Kirim ke PUT /api/dosen/pengajuan-kompen/{id}/status
            final result = await context
                .read<DataService>()
                .updateStatusPengajuan(p.id, 'diterima');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? '✅ Pengajuan diterima! Notifikasi dikirim ke mahasiswa.'
                        : '❌ ${result['message']}',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppTheme.accentGreen
                      : AppTheme.accentRed,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
          ),
          child: const Text('Terima'),
        ),
      ],
    ),
  );
}

void _showTolakDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Tolak Pengajuan'),
      content: const Text('Yakin ingin menolak pengajuan ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // ✅ Kirim ke PUT /api/dosen/pengajuan-kompen/{id}/status
            final result = await context
                .read<DataService>()
                .updateStatusPengajuan(p.id, 'ditolak');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? '❌ Pengajuan ditolak. Notifikasi dikirim ke mahasiswa.'
                        : '❌ ${result['message']}',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppTheme.accentOrange
                      : AppTheme.accentRed,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
          child: const Text('Tolak'),
        ),
      ],
    ),
  );
}

// ─── Card riwayat (sudah diproses) ───────────────────────────────────────────
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
