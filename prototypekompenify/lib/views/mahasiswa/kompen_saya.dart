import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_service.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KompenSayaScreen extends StatelessWidget {
  const KompenSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final list = svc.pengajuanSaya;

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
                    'Kompen Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${list.length} pengajuan',
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
                    context.read<DataService>().refreshDataMahasiswa(),
                child: list.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 400,
                            child: EmptyState(
                              icon: Icons.task_alt_outlined,
                              title: 'Belum ada kompen',
                              subtitle:
                                  'Pilih assignment di tab Assignment untuk mulai',
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) => _KompenApiCard(
                          pengajuan: list[i],
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                                  KompenDetailScreen(pengajuan: list[i]),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KompenApiCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final VoidCallback onTap;
  const _KompenApiCard({required this.pengajuan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.assignmentJudul ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.assignmentJamKompen ?? 0} jam kompen',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(DateTime.tryParse(p.createdAt) ?? DateTime.now()),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: p.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: p.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KompenDetailScreen extends StatelessWidget {
  final PengajuanModel pengajuan;
  const KompenDetailScreen({super.key, required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final p = svc.pengajuanSaya.firstWhere(
      (x) => x.id == pengajuan.id,
      orElse: () => pengajuan,
    );

    // 🚀 SINKRONISASI EVALUASI BOOLEAN ENUM BARU SULTAN:
    final bool isPending = p.status == 'pending';
    final bool isSedangDikerjakan = p.status == 'sedang dikerjakan';
    final bool isMenungguTTDDosen = p.status == 'menunggu_ttd_dosen';
    final bool isMenungguTTDKaprodi = p.status == 'menunggu_ttd_kaprodi';
    // final bool isDiterima = p.status == 'diterima';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kompen'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.statusColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(p.status), color: p.statusColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.statusLabel,
                            style: TextStyle(
                              color: p.statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _statusDesc(p.status),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Kompen',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      label: 'Tanggal Pengajuan',
                      value: DateFormat('dd MMM yyyy HH:mm').format(
                        DateTime.tryParse(p.createdAt) ?? DateTime.now(),
                      ),
                    ),
                    InfoRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: p.statusLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 🖼️ TAMPILKAN AREA FOTO UNTUK SEMUA TAHAP KECUALI PENDING / DITOLAK
              if (!isPending && p.status != 'ditolak') ...[
                _BuktiFotoSection(pengajuan: p),
                const SizedBox(height: 12),
              ],

              // 🚀 GERBANG TOMBOL AKSI MAHASISWA BERDASARKAN STATUS ENUM BARU
              if (isSedangDikerjakan) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _uploadBukti(context, p),
                    icon: const Icon(Icons.camera_alt_rounded, size: 16),
                    label: const Text('Upload Bukti Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _tandaiSelesai(context, p),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Kirim Hasil Kerja ke Dosen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],

              if (isMenungguTTDDosen || isMenungguTTDKaprodi) ...[
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
                        Icons.hourglass_empty_rounded,
                        color: AppTheme.accentOrange,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tugas berhasil dikirim. Menunggu proses penandatanganan dan pengesahan digital.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (isPending) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _batalkan(context, p),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppTheme.accentRed,
                    ),
                    label: const Text(
                      'Batalkan Pengajuan',
                      style: TextStyle(color: AppTheme.accentRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppTheme.accentRed),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'sedang dikerjakan':
        return Icons.build_circle_rounded;
      case 'menunggu_ttd_dosen':
        return Icons.hourglass_top_rounded;
      case 'menunggu_ttd_kaprodi':
        return Icons.rate_review_rounded;
      case 'diterima':
        return Icons.check_circle_rounded;
      case 'ditolak':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  String _statusDesc(String s) {
    switch (s) {
      case 'pending':
        return 'Menunggu slot dikunci oleh dosen';
      case 'sedang dikerjakan':
        return 'Silakan kerjakan tugas, upload foto bukti, lalu klik kirim!';
      case 'menunggu_ttd_dosen':
        return 'Berkas tugas sudah di meja dosen untuk diperiksa dan di-TTD';
      case 'menunggu_ttd_kaprodi':
        return 'Dosen sudah ACC, berkas mengantre tanda tangan Ketua Program Studi';
      case 'diterima':
        return 'Selamat! Kompen resmi SAH, LUNAS, dan SELESAI TOTAL! 🎉';
      case 'ditolak':
        return 'Pendaftaran slot ditolak dosen atau tugas dikembalikan untuk revisi';
      default:
        return s;
    }
  }

  Future<void> _uploadBukti(BuildContext context, PengajuanModel p) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;
    if (picked.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 foto'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }
    final files = picked.map((x) => File(x.path)).toList();
    final result = await context.read<DataService>().uploadBuktiFoto(
      p.id,
      files,
    );
    if (context.mounted) {
      await context.read<DataService>().fetchPengajuanSaya();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? '✅ ${result['message']}'
                : '❌ ${result['message']}',
          ),
          backgroundColor: result['success'] == true
              ? AppTheme.accentGreen
              : AppTheme.accentRed,
        ),
      );
    }
  }

  void _tandaiSelesai(BuildContext context, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Kirim Hasil Kerja?'),
        content: const Text(
          'Pastikan kamu sudah mengunggah semua bukti foto sebelum mengirimkan tugas ke dosen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Nembak API tandaiSelesai kelompok lu (mengubah status ke menunggu_ttd_dosen)
              final result = await context.read<DataService>().tandaiSelesai(
                p.id,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✅ Tugas berhasil dikirim ke dosen!'
                          : '❌ ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                  ),
                );
                if (result['success'] == true) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('Kirim Tugas'),
          ),
        ],
      ),
    );
  }

  void _batalkan(BuildContext context, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Batalkan Kompen?'),
        content: const Text(
          'Pengajuan ini akan dihapus. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await context
                  .read<DataService>()
                  .batalkanPengajuan(p.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✅ Pengajuan dibatalkan'
                          : '❌ ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                  ),
                );
                if (result['success'] == true) Navigator.pop(context);
              }
            },
            child: const Text(
              'Batalkan',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuktiFotoSection extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _BuktiFotoSection({required this.pengajuan});

  String _fixUrl(String url) {
    String cleanUrl = url.replaceAll('/api/storage/', '/storage/');
    String? domain = dotenv.env['NGROK_URL'] ?? dotenv.env['BASE_URL'];

    if (domain != null && domain.isNotEmpty) {
      if (domain.endsWith('/api')) {
        domain = domain.substring(0, domain.length - 4);
      } else if (domain.endsWith('/api/')) {
        domain = domain.substring(0, domain.length - 5);
      }
      if (domain.endsWith('/')) {
        domain = domain.substring(0, domain.length - 1);
      }
      if (cleanUrl.contains('storage/')) {
        final String pathSetelahStorage = cleanUrl.split('storage/')[1];
        return '$domain/storage/$pathSetelahStorage';
      }
    }

    String fallbackUrl = cleanUrl.replaceAll('localhost', '10.0.2.2');
    fallbackUrl = fallbackUrl.replaceAll('127.0.0.1', '10.0.2.2');
    return fallbackUrl;
  }

  @override
  Widget build(BuildContext context) {
    final buktiList = pengajuan.buktiFotos;
    debugPrint('🖼️ buktiFotos: $buktiList');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti Foto',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (buktiList.isEmpty)
            const Text(
              'Belum ada bukti foto diupload',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buktiList.map((url) {
                final fixedUrl = _fixUrl(url);
                final Map<String, String> ngrokHeaders = {
                  'ngrok-skip-browser-warning': 'true',
                };

                return GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          fixedUrl,
                          headers: ngrokHeaders,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text(
                              'Gagal menampilkan detail foto',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fixedUrl,
                      headers: ngrokHeaders,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              width: 80,
                              height: 80,
                              color: AppTheme.bgCardLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.bgCardLight,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
