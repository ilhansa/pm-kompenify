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
    // GET | Ambil data pengajuan terupdate saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().fetchPengajuanMenungguVerifikasi();
    });
  }

  void _eksekusiTandaTangan(
    BuildContext context,
    String id,
    String roleLabel,
  ) async {
    // Menembak endpoint baru /ttd yang kalian buat di Laravel
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

      // Auto refresh list data setelah berhasil dapet TTD
      if (result['success'] == true) {
        context.read<DataService>().fetchPengajuanMenungguVerifikasi();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    // AMBIL DATA: Yang statusnya sudah 'diterima' (lolos seleksi awal)
    // Tapi salah satu TTD (Dosen atau Kaprodi) masih kosong melompong
    final listAntreanTTD = svc.pengajuanMenungguVerifikasi
        .where(
          (p) =>
              p.status == 'diterima' &&
              (p.qrTokenDosen == null || p.qrTokenKaprodi == null),
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
                    'Tanda Tangan Digital',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${listAntreanTTD.length} dokumen mengantre tanda tangan',
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
                child: listAntreanTTD.isEmpty
                    ? const Center(
                        child: EmptyState(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Tidak ada antrean E-TTD malam ini',
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: listAntreanTTD.length,
                        itemBuilder: (context, index) {
                          final p = listAntreanTTD[index];
                          return _CardAntreanTtd(
                            pengajuan: p,
                            onTapTTD: (role) =>
                                _eksekusiTandaTangan(context, p.id, role),
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

// ─── CUSTOM CARD KHUSUS ANTREAN TTD ──────────────────────────────────────────
class _CardAntreanTtd extends StatelessWidget {
  final PengajuanModel pengajuan;
  final Function(String role) onTapTTD;

  const _CardAntreanTtd({required this.pengajuan, required this.onTapTTD});

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
          color: const Color(0xFF6C63FF).withOpacity(0.4),
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
                label: p.qrTokenDosen == null
                    ? 'Butuh TTD Dosen'
                    : 'Butuh TTD Kaprodi',
                color: p.qrTokenDosen == null
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF00B4D8),
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
            label: 'Total Waktu',
            value: '${p.assignmentJamKompen ?? 0} jam',
          ),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Lolos Validasi',
            value: timeago.format(
              DateTime.tryParse(p.createdAt) ?? DateTime.now(),
              locale: 'id',
            ),
          ),
          const SizedBox(height: 14),

          // DINAMIS BUTTON: Menyesuaikan progres tanda tangan digital
          if (p.qrTokenDosen == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onTapTTD('Dosen'),
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
                onPressed: () => onTapTTD('Kaprodi'),
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text(
                  'Sahkan Sebagai Kaprodi (E-TTD)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8), // Biru Segar
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// widget pembantu untuk judul agar tertata rapi
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 12.0,
      ), // ✅ FIXED: Pakai top, bukan vertical! Anti-Garis Merah!
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
