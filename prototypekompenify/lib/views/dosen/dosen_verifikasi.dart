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

    // 🚀 TAB 1: Mahasiswa baru daftar slot (Status masih 'pending')
    final listPerluPersetujuan = svc.pengajuanMenungguVerifikasi
        .where((p) => p.status == 'pending')
        .toList();

    // 🚀 TAB 2: Sudah disetujui kerja, sekarang masuk antrean TTD Digital berjenjang
    final listButuhTTD = svc.pengajuanMenungguVerifikasi
        .where(
          (p) =>
              p.status == 'diterima' &&
              (p.qrTokenDosen == null || p.qrTokenKaprodi == null),
        )
        .toList();

    // 🚀 TAB 3: Riwayat pengajuan yang sudah ditolak ATAU sudah dapet semua TTD sah
    final history = svc.pengajuanMenungguVerifikasi
        .where(
          (p) =>
              p.status == 'ditolak' ||
              (p.status == 'diterima' &&
                  p.qrTokenDosen != null &&
                  p.qrTokenKaprodi != null),
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
                    'Manajemen Verifikasi Kompen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${listPerluPersetujuan.length} butuh persetujuan awal | ${listButuhTTD.length} butuh E-TTD',
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
                    // ─── BAGIAN 1: SELEKSI REBUTAN SLOT ───
                    if (listPerluPersetujuan.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Persetujuan Slot Kerja Mahasiswa',
                      ),
                      ...listPerluPersetujuan.map(
                        (p) => _VerifikasiCard(pengajuan: p, isTTDMode: false),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── BAGIAN 2: PROSES GENERATE QR E-TTD ───
                    if (listButuhTTD.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Antrean Tanda Tangan Digital (E-TTD)',
                      ),
                      ...listButuhTTD.map(
                        (p) => _VerifikasiCard(pengajuan: p, isTTDMode: true),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Jika dua-duanya kosong melompong
                    if (listPerluPersetujuan.isEmpty && listButuhTTD.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: EmptyState(
                          icon: Icons.done_all_rounded,
                          title: 'Semua tugas bersih terproses!',
                        ),
                      ),

                    // ─── BAGIAN 3: RIWAYAT FINAL ───
                    if (history.isNotEmpty) ...[
                      const SectionTitle(title: 'Riwayat Pengajuan Selesai'),
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

// Widget pembantu untuk judul section agar rapi
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

// ─── CARD VERIFIKASI UTAMA ───────────────────────────────────────────────────
class _VerifikasiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final bool isTTDMode; // Pembeda kartu seleksi awal vs kartu tanda tangan

  const _VerifikasiCard({required this.pengajuan, required this.isTTDMode});

  // Fungsi memicu generate token QR tanpa merusak status lama
  void _prosesGenerateQR(
    BuildContext context,
    String id,
    String roleLabel,
  ) async {
    // Menembak endpoint baru /generate-ttd yang disiapkan teman backend-mu
    final result = await context.read<DataService>().updateStatusPengajuan(
      id,
      'generate-ttd',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? '✓ Sukses menyematkan E-TTD $roleLabel! Kode QR sah terbit.'
                : '❌ Gagal: ${result['message']}',
          ),
          backgroundColor: result['success'] == true
              ? AppTheme.accentGreen
              : AppTheme.accentRed,
        ),
      );
      if (result['success'] == true) {
        context.read<DataService>().fetchPengajuanMenungguVerifikasi();
      }
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
        border: Border.all(
          color: isTTDMode
              ? const Color(0xFF6C63FF).withOpacity(0.5)
              : AppTheme.accentOrange.withOpacity(0.4),
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
              // Jika isTTDMode aktif, tampilin informasi progres TTD-nya saat ini
              isTTDMode
                  ? StatusBadge(
                      label: p.qrTokenDosen == null
                          ? 'Belum TTD Dosen'
                          : 'Belum TTD Kaprodi',
                      color: p.qrTokenDosen == null
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF00B4D8),
                    )
                  : StatusBadge(label: p.statusLabel, color: p.statusColor),
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

          // Tampilan Galeri Bukti Foto (Tampilkan jika sudah di-upload mahasiswa)
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

          // 🚀 TOMBOL AKSI BERDASARKAN MODE KATEGORI
          if (!isTTDMode) ...[
            // KATEGORI SELEKSI AWAL: Balik ke struktur lama biar aman dari eror backend
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
          ] else ...[
            // KATEGORI GENERATE TTD: Tombol mandiri cerdas berjenjang
            if (p.qrTokenDosen == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _prosesGenerateQR(context, p.id, 'Dosen'),
                  icon: const Icon(Icons.draw_outlined, size: 18),
                  label: const Text(
                    'Bubuhkan E-TTD Dosen',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF), // Ungu Modis
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (p.qrTokenKaprodi == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _prosesGenerateQR(context, p.id, 'Kaprodi'),
                  icon: const Icon(Icons.verified_user_outlined, size: 18),
                  label: const Text(
                    'Sahkan Sebagai Kaprodi (E-TTD)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

// Dialog pendukung proses terima awal (Mengirimkan string 'diterima' asli bawaan backend kamu)
void _showTerimaDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.accentGreen),
          SizedBox(width: 8),
          Text('Pilih Mahasiswa'),
        ],
      ),
      content: Text(
        'Pilih ${p.mahasiswaNama ?? "mahasiswa"} untuk mengerjakan tugas kompen ini?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // ✅ BALIK KE SETTINGAN LAMA: Kirim kata 'diterima' asli biar lolos validasi Laravel
            final result = await context
                .read<DataService>()
                .updateStatusPengajuan(p.id, 'diterima');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? '✅ Sukses memilih mahasiswa! Slot pengerjaan resmi dikunci.'
                        : '❌ ${result['message']}',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppTheme.accentGreen
                      : AppTheme.accentRed,
                ),
              );
              if (result['success'] == true) {
                context.read<DataService>().fetchPengajuanMenungguVerifikasi();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
          ),
          child: const Text('Pilih'),
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
      title: const Text('Tolak Pengajuan Slot'),
      content: const Text(
        'Yakin ingin menolak pendaftaran slot mahasiswa ini?',
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
                        ? '❌ Pendaftaran slot ditolak.'
                        : '❌ ${result['message']}',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppTheme.accentOrange
                      : AppTheme.accentRed,
                ),
              );
              if (result['success'] == true) {
                context.read<DataService>().fetchPengajuanMenungguVerifikasi();
              }
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
