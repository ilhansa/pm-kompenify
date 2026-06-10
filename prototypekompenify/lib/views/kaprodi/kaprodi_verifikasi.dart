// lib/views/kaprodi/kaprodi_verifikasi.dart
// Menggunakan AuthController untuk interaksi aksi REST API, dan KaprodiController untuk pemantauan tiga lapis data pimpinan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/auth_controller.dart';
import '../../controllers/kaprodi_controller.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Memperbarui profil secara terpusat yang otomatis memuat ulang data seluruh controller pimpinan
      context.read<AuthController>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kaprodiController = context.watch<KaprodiController>();
    final antreanKaprodi = kaprodiController.pengajuanMenungguVerifikasiKaprodi;

    // 🚀 KATEGORI 1: TUGAS MILIK KAPRODI SENDIRI (WAR SLOT)
    final listSeleksiSlot = antreanKaprodi
        .where((p) => p.status == 'pending')
        .toList();

    // 🚀 KATEGORI 2: TUGAS MILIK KAPRODI SENDIRI (MONITORING KERJA)
    final listMonitoring = antreanKaprodi
        .where(
          (p) =>
              p.status == 'sedang dikerjakan' ||
              p.status == 'menunggu_ttd_dosen',
        )
        .toList();

    // 🚀 KATEGORI 3: TUGAS SE-KAMPUS YANG NUNGGU ACC MUTLAK (Saringan Utama)
    final listApprovalAkhir = antreanKaprodi
        .where((p) => p.status == 'menunggu_ttd_kaprodi')
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
                    'Pusat Validasi Kaprodi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${listApprovalAkhir.length} Antrean TTD Akhir | ${listSeleksiSlot.length + listMonitoring.length} Tugas Pribadi',
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
                    context.read<AuthController>().refreshProfile(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // ─── SECTION 3 (PALING ATAS): PENGESAHAN AKHIR KAPRODI ───
                    if (listApprovalAkhir.isNotEmpty) ...[
                      const SectionTitle(
                        title: '🔴 Otoritas Mutlak: Antrean E-TTD Kaprodi',
                      ),
                      ...listApprovalAkhir.map(
                        (p) => _VerifikasiCard(
                          pengajuan: p,
                          mode: 'approval_akhir',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── SECTION 1: PERSETUJUAN SLOT WAR (Tugas Sendiri) ───
                    if (listSeleksiSlot.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Tugas Pribadi: Seleksi Slot Mahasiswa',
                      ),
                      ...listSeleksiSlot.map(
                        (p) => _VerifikasiCard(pengajuan: p, mode: 'seleksi'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── SECTION 2: MONITORING KERJA (Tugas Sendiri) ───
                    if (listMonitoring.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Tugas Pribadi: Evaluasi Pengerjaan',
                      ),
                      ...listMonitoring.map(
                        (p) =>
                            _VerifikasiCard(pengajuan: p, mode: 'monitoring'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Jika layar kosong melompong
                    if (listSeleksiSlot.isEmpty &&
                        listMonitoring.isEmpty &&
                        listApprovalAkhir.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyState(
                          icon: Icons.verified_user_rounded,
                          title: 'Semua antrean bersih, Bos!',
                        ),
                      ),
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

// ─── CARD WIDGET MULTI-FUNGSI KAPRODI ───
class _VerifikasiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final String mode; // 'seleksi', 'monitoring', 'approval_akhir'

  const _VerifikasiCard({required this.pengajuan, required this.mode});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    final bool isUdahSelesai = p.status == 'menunggu_ttd_dosen';
    final bool isApprovalAkhir = mode == 'approval_akhir';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApprovalAkhir
              ? AppTheme.accentGreen.withOpacity(0.5)
              : (mode == 'monitoring'
                    ? (isUdahSelesai
                          ? const Color(0xFF6C63FF).withOpacity(0.5)
                          : Colors.white10)
                    : AppTheme.accentOrange.withOpacity(0.4)),
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
              StatusBadge(
                label: isApprovalAkhir
                    ? 'Menunggu E-TTD'
                    : (mode == 'monitoring'
                          ? (isUdahSelesai
                                ? 'Menunggu ACC'
                                : 'Sedang Dikerjakan')
                          : p.statusLabel),
                color: isApprovalAkhir
                    ? AppTheme.accentGreen
                    : (mode == 'monitoring'
                          ? (isUdahSelesai
                                ? const Color(0xFF6C63FF)
                                : Colors.grey)
                          : p.statusColor),
              ),
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
            label: 'Jam Kompen',
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

          // Galeri bukti pengerjaan digital mahasiswa
          if ((mode == 'monitoring' && isUdahSelesai) || isApprovalAkhir) ...[
            const SizedBox(height: 12),
            const Text(
              'File Bukti Pengerjaan:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            if (p.buktiFotos.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: p.buktiFotos.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        p.buktiFotos[idx],
                        fit: BoxFit.cover,
                        width: 140,
                        headers: const {'ngrok-skip-browser-warning': 'true'},
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.accentOrange,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak ada bukti foto digital yang diunggah.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 14),

          // ─── TOMBOL AKSI BERDASARKAN MODE DINAMIS ───
          if (mode == 'seleksi') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showTolakDialog(context, p),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Tolak Pendaftar',
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showTerimaDialog(context, p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Pilih Mahasiswa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (mode == 'monitoring') ...[
            if (!isUdahSelesai)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Sedang Dikerjakan Mahasiswa...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRevisiDialog(context, p),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentRed),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Tolak / Revisi',
                        style: TextStyle(
                          color: AppTheme.accentRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Menembak verifikasiPengajuan bawa status diterima & role kaprodi lewat AuthController
                        final result = await context
                            .read<AuthController>()
                            .verifikasiPengajuan(
                              id: p.id,
                              status: 'diterima',
                              role: 'kaprodi',
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ??
                                    'Status berhasil diperbarui',
                              ),
                              backgroundColor: result['success'] == true
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                            ),
                          );
                          if (result['success'] == true) {
                            context.read<AuthController>().refreshProfile();
                          }
                        }
                      },
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text(
                        'ACC Kerjaan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
          ] else if (mode == 'approval_akhir') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRevisiDialog(context, p),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Kembalikan / Tolak',
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSahDialog(context, p),
                    icon: const Icon(Icons.verified_rounded, size: 14),
                    label: const Text(
                      'SAHKAN (Lunas)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
}

// ─── KUMPULAN DIALOG AKSI KAPRODI ───
void _showTerimaDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Pilih Mahasiswa'),
      content: Text('Kunci slot tugas ini untuk ${p.mahasiswaNama}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final result = await context
                .read<AuthController>()
                .verifikasiPengajuan(
                  id: p.id,
                  status: 'diterima',
                  role: 'kaprodi',
                );
            if (context.mounted && result['success'] == true) {
              context.read<AuthController>().refreshProfile();
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
      title: const Text('Tolak Pendaftar'),
      content: const Text('Yakin menolak pendaftaran mahasiswa ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final result = await context
                .read<AuthController>()
                .verifikasiPengajuan(
                  id: p.id,
                  status: 'ditolak',
                  role: 'kaprodi',
                );
            if (context.mounted && result['success'] == true) {
              context.read<AuthController>().refreshProfile();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
          child: const Text('Tolak'),
        ),
      ],
    ),
  );
}

void _showRevisiDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Tolak / Revisi'),
      content: const Text(
        'Kembalikan status pengerjaan mahasiswa ini untuk direvisi?',
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
                .read<AuthController>()
                .verifikasiPengajuan(
                  id: p.id,
                  status: 'ditolak',
                  role: 'kaprodi',
                );
            if (context.mounted && result['success'] == true) {
              context.read<AuthController>().refreshProfile();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
          child: const Text('Tolak'),
        ),
      ],
    ),
  );
}

void _showSahDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Pengesahan Final (E-TTD)'),
      content: const Text(
        'Yakin ingin memberikan stempel lunas mutlak? Sistem akan menyematkan QR Code E-TTD Kaprodi pada surat bebas kompen milik mahasiswa.',
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
                .read<AuthController>()
                .verifikasiPengajuan(
                  id: p.id,
                  status: 'diterima',
                  role: 'kaprodi',
                );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['message'] ?? 'Berhasil disahkan mutlak',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppTheme.accentGreen
                      : AppTheme.accentRed,
                ),
              );
              if (result['success'] == true) {
                context.read<AuthController>().refreshProfile();
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Sahkan Mutlak'),
        ),
      ],
    ),
  );
}
