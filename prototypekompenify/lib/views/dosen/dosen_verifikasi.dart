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

    // 🚀 KATEGORI 1: REBUTAN SLOT WAR (Status database murni 'pending')
    final listSeleksiSlot = svc.pengajuanMenungguVerifikasi
        .where((p) => p.status == 'pending')
        .toList();

    // 🚀 KATEGORI 2: MONITORING PROSES & EVALUASI KERJA (Status 'sedang dikerjakan' ATAU 'menunggu_ttd_dosen')
    // Sesuai request Sultan, data tetep ditampilkan di dosen pas mahasiswa lagi proses nugas!
    final listMonitoring = svc.pengajuanMenungguVerifikasi
        .where(
          (p) =>
              p.status == 'sedang dikerjakan' ||
              p.status == 'menunggu_ttd_dosen',
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
                    '${listSeleksiSlot.length} butuh slot | ${listMonitoring.length} dalam pemantauan tugas',
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
                    // ─── SECTION 1: PERSETUJUAN SLOT WAR ───
                    if (listSeleksiSlot.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Persetujuan Slot Kerja Mahasiswa',
                      ),
                      ...listSeleksiSlot.map(
                        (p) => _VerifikasiCard(
                          pengajuan: p,
                          isMonitoringMode: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── SECTION 2: MONITORING & CEK HASIL TUGAS ───
                    if (listMonitoring.isNotEmpty) ...[
                      const SectionTitle(
                        title: 'Proses Pengerjaan & Evaluasi Tugas',
                      ),
                      ...listMonitoring.map(
                        (p) => _VerifikasiCard(
                          pengajuan: p,
                          isMonitoringMode: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Jika layar bener-bener kosong melompong
                    if (listSeleksiSlot.isEmpty && listMonitoring.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyState(
                          icon: Icons.assignment_turned_in_rounded,
                          title: 'Semua antrean tugas bersih terproses!',
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

// ─── CARD WIDGET UTAMA DENGAN LOGIKA TOMBOL DINAMIS ─────────────────────────
class _VerifikasiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final bool isMonitoringMode;

  const _VerifikasiCard({
    required this.pengajuan,
    required this.isMonitoringMode,
  });

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    final svc = context.read<DataService>();

    // Cek kondisi apakah mhs beneran udah klik selesai nugas atau masih merangkak ngerjain
    final bool isUdahSelesai = p.status == 'menunggu_ttd_dosen';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMonitoringMode
              ? (isUdahSelesai
                    ? const Color(0xFF6C63FF).withOpacity(0.5)
                    : Colors.white10)
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
              StatusBadge(
                label: isMonitoringMode
                    ? (isUdahSelesai ? 'Menunggu ACC' : 'Sedang Dikerjakan')
                    : p.statusLabel,
                color: isMonitoringMode
                    ? (isUdahSelesai ? const Color(0xFF6C63FF) : Colors.grey)
                    : p.statusColor,
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

          // 🚀 AREA GALERI BUKTI HORIZONTAL (HANYA MUNCUL KALAU MONITORING & MAHASISWA UDAH KELAR)
          if (isMonitoringMode && isUdahSelesai) ...[
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
              // Tampilan jika mhs ngumpulin tanpa bukti foto (Tetap aman bisa di-ACC!)
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
                        'Tanpa bukti foto. Silakan konfirmasi fisik / manual ke mahasiswa.',
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

          // 🚀 TOMBOL AKSI WORKFLOW SULTAN
          if (!isMonitoringMode) ...[
            // ─── FASE A: SELEKSI REBUTAN SLOT ───
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
          ] else ...[
            // ─── FASE B: MONITORING & EVALUASI KERJA ───
            if (!isUdahSelesai)
              // Jika status masih 'sedang dikerjakan', tombol dikunci biar dosen ga salah pencet ACC duluan
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
                      'Mahasiswa Sedang Mengerjakan Tugas...',
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
              // Jika status udah 'menunggu_ttd_dosen', tombol ACC & Tolak menyala gagah!
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
                        'Tolak / Catat Revisi',
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
                        // ACC KERJAAN: Nembak rute updateStatus bawa string 'diterima'
                        final result = await svc.updateStatusPengajuan(
                          p.id,
                          'diterima',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['success'] == true
                                    ? '✅ Kerja Valid! Berkas dikirim ke halaman E-TTD.'
                                    : '❌ Gagal: ${result['message']}',
                              ),
                              backgroundColor: result['success'] == true
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                            ),
                          );
                          if (result['success'] == true)
                            svc.fetchPengajuanMenungguVerifikasi();
                        }
                      },
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text(
                        'ACC & Kirim ke Meja TTD',
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
          ],
        ],
      ),
    );
  }
}

// ─── KUMPULAN DIALOG AKSI (SINKRON KE CONTROLLER LARAVEL BARU) ────────────────
void _showTerimaDialog(BuildContext context, PengajuanModel p) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Pilih Mahasiswa'),
      content: Text(
        'Kunci slot tugas kompen ini untuk ${p.mahasiswaNama ?? "mahasiswa"}? Mahasiswa lain otomatis tertolak.',
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
                .updateStatusPengajuan(p.id, 'diterima');
            if (context.mounted && result['success'] == true) {
              context.read<DataService>().fetchPengajuanMenungguVerifikasi();
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
      title: const Text('Tolak Pendaftar Slot'),
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
            if (context.mounted && result['success'] == true) {
              context.read<DataService>().fetchPengajuanMenungguVerifikasi();
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
      title: const Text('Tolak Hasil Kerja'),
      content: const Text(
        'Yakin ingin menolak hasil kerjaan ini? Status mahasiswa akan dikembalikan ke posisi wajib revisi.',
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
            if (context.mounted && result['success'] == true) {
              context.read<DataService>().fetchPengajuanMenungguVerifikasi();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
          child: const Text('Tolak & Revisi'),
        ),
      ],
    ),
  );
}
