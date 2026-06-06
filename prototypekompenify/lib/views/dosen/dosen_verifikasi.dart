// lib/views/dosen/dosen_verifikasi.dart
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().fetchPengajuanMenungguVerifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    // 🚀 FILTER WORKFLOW BARU: Masuk tab "Perlu Diproses" jika butuh approval awal ATAU butuh TTD
    final list = svc.pengajuanMenungguVerifikasi
        .where(
          (p) =>
              p.status == 'pending' ||
              p.status == 'menunggu_ttd_dosen' ||
              p.status == 'menunggu_ttd_kaprodi',
        )
        .toList();

    // Masuk tab "Riwayat" jika sudah final (diterima/ditolak)
    final history = svc.pengajuanMenungguVerifikasi
        .where((p) => p.status == 'diterima' || p.status == 'ditolak')
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
                    'Verifikasi & E-TTD Kompen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${list.length} tugas aktif perlu diproses',
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
                          title: 'Semua tugas bersih terproses!',
                        ),
                      )
                    else
                      ...list.map((p) => _VerifikasiCard(pengajuan: p)),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Riwayat Pengajuan Final',
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

// ─── CARD VERIFIKASI DENGAN TOMBOL DINAMIS WORKFLOW ───────────────────────────
class _VerifikasiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _VerifikasiCard({required this.pengajuan});

  // Fungsi pembantu untuk memicu proses TTD Digital berjenjang via API baru
  void _eksekusiTandaTangan(
    BuildContext context,
    String id,
    String roleLabel,
  ) async {
    // 🚀 Panggil API /ttd baru kelompokmu via DataService
    // Pastikan di DataService tim kamu sudah ada fungsi beralur POST/POST: 'berikanTandaTangan(id)'
    final result = await context.read<DataService>().updateStatusPengajuan(
      id,
      'ttd',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? '✓ E-TTD $roleLabel sukses disematkan! Kode QR aman ter-generate.'
                : '❌ Gagal TTD: ${result['message']}',
          ),
          backgroundColor: result['success'] == true
              ? AppTheme.accentGreen
              : AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.statusColor.withOpacity(0.4), width: 1.5),
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

          // Tampilan Galeri Bukti Foto
          if (p.buktiFotos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
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

          // 🚀 EKSEKUSI UTAMA: LOGIKA TOMBOL DINAMIS WORKFLOW BARU
          if (p.status == 'pending') ...[
            // TAHAP 1: Approval kelayakan awal tugas kompen
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
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text(
                      'Terima Kerja',
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
          ] else if (p.status == 'menunggu_ttd_dosen') ...[
            // TAHAP 2: Mahasiswa selesai ngerjain, Dosen bubuhkan TTD Digital
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _eksekusiTandaTangan(context, p.id, 'Dosen'),
                icon: const Icon(
                  Icons.draw_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Bubuhkan E-TTD Dosen',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF), // Ungu Modis
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else if (p.status == 'menunggu_ttd_kaprodi') ...[
            // TAHAP 3: Giliran meja Kaprodi yang eksekusi tanda tangan segel akhir
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _eksekusiTandaTangan(context, p.id, 'Kaprodi'),
                icon: const Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Sahkan Sebagai Kaprodi (E-TTD)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF00B4D8,
                  ), // Biru Segar Kaprodi
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Dialog-dialog pendukung proses terima/tolak awal
void _showTerimaDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.accentGreen),
          SizedBox(width: 8),
          Text('Setujui Pengajuan'),
        ],
      ),
      content: Text(
        'Setujui pengerjaan kompen oleh ${p.mahasiswaNama ?? "mahasiswa"}?\n\nStatus akan beralih ke penantian E-TTD pengerjaan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // Naikin status dari pending -> menunggu_ttd_dosen
            final result = await context
                .read<DataService>()
                .updateStatusPengajuan(p.id, 'menunggu_ttd_dosen');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? '✅ Berhasil disetujui! Status beralih ke tahap TTD.'
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
          child: const Text('Setujui'),
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
      content: const Text(
        'Yakin ingin menolak pengajuan kompen mahasiswa ini?',
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
                .updateStatusPengajuan(p.id, 'ditolak');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? '❌ Pengajuan ditolak resmi.'
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

// ─── CARD RIWAYAT FINAL ──────────────────────────────────────────────────────
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
