// lib/views/kaprodi/kaprodi_approval.dart
// Menggunakan AuthController untuk otentikasi & verifikasi, serta KaprodiController untuk antrean berkas meja pimpinan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/auth_controller.dart';
import '../../controllers/kaprodi_controller.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

// DIUBAH MENJASI STATEFULWIDGET AGAR BISA MEMASANG INITSTATE UNTUK FETCH API LARAVEL LORR
class KaprodiApproval extends StatefulWidget {
  const KaprodiApproval({super.key});

  @override
  State<KaprodiApproval> createState() => _KaprodiApprovalState();
}

class _KaprodiApprovalState extends State<KaprodiApproval> {
  @override
  void initState() {
    super.initState();
    // AMBIL DATA ANTREAN SURAT DARI BACKEND BEGITU HALAMAN DIBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatUlangDataKaprodi();
    });
  }

  // Fungsi sakti untuk memicu fetch data antrean verifikasi Kaprodi
  void _muatUlangDataKaprodi() {
    final token = context.read<AuthController>().token ?? '';
    context.read<KaprodiController>().fetchPengajuanMenungguVerifikasiKaprodi(
      token,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mengakses state koleksi berkas pimpinan dari KaprodiController
    final kaprodiController = context.watch<KaprodiController>();
    final antreanKaprodi = kaprodiController.pengajuanMenungguVerifikasiKaprodi;

    // FILTER SAKTI SULTAN (SUPER AMAN & KEBAL HURUF BESAR/KECIL DARI LARAVEL):
    final pending = antreanKaprodi
        .where(
          (p) =>
              p.status.toString().toLowerCase().trim() ==
              'menunggu_ttd_kaprodi',
        )
        .toList();

    // Riwayat adalah berkas yang sudah resmi disahkan lunas total oleh Kaprodi
    final history = antreanKaprodi.where((p) {
      final s = p.status.toString().toLowerCase().trim();
      return s == 'selesai' || s == 'diterima';
    }).toList();

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
                    'Meja E-TTD Utama Kaprodi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${pending.length} dokumen mahasiswa mengantre tanda tangan pimpinan Anda',
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
                onRefresh: () async {
                  await context.read<AuthController>().refreshProfile();
                  _muatUlangDataKaprodi();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (pending.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: EmptyState(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Meja TTD Pimpinan Bersih, Pak/Bu Kaprodi!',
                        ),
                      )
                    else
                      ...pending.map(
                        (p) => _ApprovalCard(
                          pengajuan: p,
                          onSelesaiAksi: _muatUlangDataKaprodi,
                        ),
                      ),

                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Riwayat Pengesahan Final',
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

// ─── ✨ DESIGN CARD PREMIUM MEJA E-TTD PIMPINAN ✨ ───────────────────────────
class _ApprovalCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final VoidCallback onSelesaiAksi;

  const _ApprovalCard({required this.pengajuan, required this.onSelesaiAksi});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    final nama = p.mahasiswaNama ?? 'Mahasiswa';
    final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  backgroundColor: const Color(0xFF00B4D8).withOpacity(0.1),
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      color: Color(0xFF00B4D8),
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
                    color: const Color(0xFF00B4D8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Lolos TTD Dosen',
                    style: TextStyle(
                      color: Color(0xFF00B4D8),
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
              label: 'Lolos Validasi Dosen',
              value: timeago.format(
                DateTime.tryParse(p.createdAt) ?? DateTime.now(),
                locale: 'id',
              ),
            ),
            const SizedBox(height: 16),

            // 🚀 TOMBOL SAKTI: Tombol Tolak Dihapus Total & Tombol Sahkan Membentang Penuh 1 Halaman Jorr!
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showTerimaDialog(context, p),
                icon: const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Sahkan Berkas & Tanda Tangan (E-TTD)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

  void _showTerimaDialog(BuildContext context, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Color(0xFF00B4D8)),
            SizedBox(width: 10),
            Text(
              'Sahkan Dokumen Final',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membubuhkan E-TTD Kaprodi pada berkas milik ${p.mahasiswaNama}? Langkah ini akan melunaskan kewajiban kompen mahasiswa secara permanen.',
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
              final token = context.read<AuthController>().token ?? '';

              // Menembak fungsi berikanTandaTanganKaprodi dari KaprodiController bawaan tim kelompokmu lorr!
              final result = await context
                  .read<KaprodiController>()
                  .berikanTandaTanganKaprodi(p.id, token);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '🎊 Berkas Kompen Berhasil Disahkan! PDF Mahasiswa Resmi Terbit.'
                          : '❌ ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (result['success'] == true) {
                  onSelesaiAksi(); // Picu panggil ulang antrean lorr!
                }
              }
            },
            child: const Text(
              'Sahkan Berkas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ✨ DESIGN CARD RIWAYAT LUNAS FINAL ✨ ───────────────────────────────────
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
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
          const StatusBadge(
            label: 'Lunas Total & Ber-QR',
            color: AppTheme.accentGreen,
          ),
        ],
      ),
    );
  }
}
