import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mahasiswa_controller.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class KompenSayaScreen extends StatefulWidget {
  const KompenSayaScreen({super.key});

  @override
  State<KompenSayaScreen> createState() => _KompenSayaScreenState();
}

class _KompenSayaScreenState extends State<KompenSayaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthController>().token ?? '';
      context.read<MahasiswaController>().fetchPengajuanSaya(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mhsController = context.watch<MahasiswaController>();
    final list = mhsController.pengajuanSaya;

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
                onRefresh: () async {
                  await context.read<AuthController>().refreshProfile();
                  final token = context.read<AuthController>().token ?? '';
                  await context.read<MahasiswaController>().fetchPengajuanSaya(token);
                },
                child: list.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 400,
                            child: EmptyState(
                              icon: Icons.task_alt_outlined,
                              title: 'Belum ada kompen',
                              subtitle: 'Pilih assignment di tab Assignment untuk mulai',
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
                              builder: (_) => KompenDetailScreen(pengajuan: list[i]),
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
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.assignmentJamKompen ?? 0} jam kompen',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(
                      DateTime.tryParse(p.createdAt) ?? DateTime.now(),
                    ),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: p.statusColor.withValues(alpha: 0.12),
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

  Future<void> _downloadPdfWithToken(BuildContext context, String id, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
    final pdfUrl = '$baseUrl/mahasiswa/pengajuan-kompen/$id/cetak-surat';

    try {
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) await Permission.storage.request();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Sedang mengunduh PDF ke folder Download...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(pdfUrl));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.acceptHeader, 'application/pdf');
      request.headers.set('X-Requested-With', 'XMLHttpRequest');

      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);

        Directory? downloadDir;
        if (Platform.isAndroid) {
          downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            downloadDir = await getExternalStorageDirectory();
          }
        } else {
          downloadDir = await getDownloadsDirectory();
        }

        final file = File('${downloadDir!.path}/Surat_Bebas_Kompen_$id.pdf');
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ PDF Sukses Diunduh!\nCek di File Manager -> Folder Download!'),
              backgroundColor: AppTheme.accentGreen,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw 'Akses ditolak Laravel! Status: ${response.statusCode}';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengunduh PDF: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mhsController = context.watch<MahasiswaController>();
    final authController = context.watch<AuthController>();
    final token = authController.token ?? '';
    final p = mhsController.pengajuanSaya.firstWhere(
      (x) => x.id == pengajuan.id,
      orElse: () => pengajuan,
    );

    final bool isPending = p.status == 'pending';
    final bool isSedangDikerjakan = p.status == 'sedang dikerjakan';
    final bool isMenungguTTDDosen = p.status == 'menunggu_ttd_dosen';
    final bool isMenungguTTDKaprodi = p.status == 'menunggu_ttd_kaprodi';
    final bool isLunasTotal = p.statusLabel == 'Selesai / Lunas' || p.status == 'diterima';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kompen'),
        backgroundColor: AppTheme.bgLight,
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
                  color: p.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.statusColor.withValues(alpha: 0.4)),
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
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p.assignmentJudul ?? '-'),
                    InfoRow(icon: Icons.schedule_outlined, label: 'Jam Kompen', value: '${p.assignmentJamKompen ?? 0} jam'),
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Pengajuan',
                      value: DateFormat('dd MMM yyyy HH:mm').format(
                        DateTime.tryParse(p.createdAt) ?? DateTime.now(),
                      ),
                    ),
                    InfoRow(icon: Icons.info_outline, label: 'Status', value: p.statusLabel),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!isPending && p.status != 'ditolak') ...[
                _BuktiFotoSection(pengajuan: p),
                const SizedBox(height: 16),
              ],

              if (isLunasTotal) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadPdfWithToken(context, p.id, token),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Cetak Surat Bebas Kompen (PDF)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (isSedangDikerjakan) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _uploadBukti(context, token, p),
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
                    onPressed: () => _tandaiSelesai(context, token, p),
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
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, color: AppTheme.accentOrange, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Tugas berhasil dikirim. Menunggu proses penandatanganan dan pengesahan digital.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
                    onPressed: () => _batalkan(context, token, p),
                    icon: const Icon(Icons.cancel_outlined, color: AppTheme.accentRed),
                    label: const Text('Batalkan Pengajuan', style: TextStyle(color: AppTheme.accentRed)),
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
      case 'sedang dikerjakan': return Icons.build_circle_rounded;
      case 'menunggu_ttd_dosen': return Icons.hourglass_top_rounded;
      case 'menunggu_ttd_kaprodi': return Icons.rate_review_rounded;
      case 'diterima': return Icons.check_circle_rounded;
      case 'ditolak': return Icons.cancel_rounded;
      default: return Icons.pending_rounded;
    }
  }

  String _statusDesc(String s) {
    switch (s) {
      case 'pending': return 'Menunggu slot dikunci oleh dosen';
      case 'sedang dikerjakan': return 'Silakan kerjakan tugas, upload foto bukti, lalu klik kirim!';
      case 'menunggu_ttd_dosen': return 'Berkas tugas sudah di meja dosen untuk diperiksa dan di-TTD';
      case 'menunggu_ttd_kaprodi': return 'Dosen sudah ACC, berkas mengantre tanda tangan Ketua Program Studi';
      case 'diterima': return 'Selamat! Kompen resmi SAH, LUNAS, dan SELESAI TOTAL! 🎉';
      case 'ditolak': return 'Pendaftaran slot ditolak dosen atau tugas dikembalikan untuk revisi';
      default: return s;
    }
  }

  Future<void> _uploadBukti(BuildContext context, String token, PengajuanModel p) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;

    if (picked.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 foto'), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    final files = picked.map((x) => File(x.path)).toList();
    final result = await context.read<MahasiswaController>().uploadBuktiFoto(token, p.id, files);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true ? '✅ ${result['message']}' : '❌ ${result['message']}'),
          backgroundColor: result['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
        ),
      );
    }
  }

  void _tandaiSelesai(BuildContext context, String token, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Kirim Hasil Kerja?'),
        content: const Text('Pastikan kamu sudah mengunggah semua bukti foto sebelum mengirimkan tugas ke dosen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await context.read<MahasiswaController>().tandaiSelesai(token, p.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success'] == true ? '✅ Tugas berhasil dikirim ke dosen!' : '❌ ${result['message']}'),
                    backgroundColor: result['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
                if (result['success'] == true) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: const Text('Kirim Tugas'),
          ),
        ],
      ),
    );
  }

  void _batalkan(BuildContext context, String token, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Batalkan Kompen?'),
        content: const Text('Pengajuan ini akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await context.read<MahasiswaController>().batalkanPengajuan(token, p.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success'] == true ? '✅ Pengajuan dibatalkan' : '❌ ${result['message']}'),
                    backgroundColor: result['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
                if (result['success'] == true) Navigator.pop(context);
              }
            },
            child: const Text('Batalkan', style: TextStyle(color: AppTheme.accentRed)),
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
      if (domain.endsWith('/api')) domain = domain.substring(0, domain.length - 4);
      else if (domain.endsWith('/api/')) domain = domain.substring(0, domain.length - 5);
      if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);
      if (cleanUrl.contains('storage/')) {
        final String pathSetelahStorage = cleanUrl.split('storage/')[1];
        return '$domain/storage/$pathSetelahStorage';
      }
    }

    String fallbackUrl = cleanUrl.replaceAll('localhost', '10.0.2.2');
    fallbackUrl = fallbackUrl.replaceAll('127.0.0.1', '10.0.2.2');
    return fallbackUrl;
  }

  Future<void> _hapusFoto(BuildContext context, String buktiId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Hapus Foto?'),
        content: const Text('Foto ini akan dihapus dari bukti kompen kamu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final token = context.read<AuthController>().token ?? '';
    // ✅ FIX: kirim buktiId (UUID foto), bukan pengajuanId
    final result = await context.read<MahasiswaController>().hapusBuktiFoto(token, buktiId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true ? '✅ Foto dihapus' : '❌ ${result['message']}'),
          backgroundColor: result['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buktiList = pengajuan.buktiFotos; // List<BuktiFotoItem>
    final bool bolehHapus = pengajuan.status == 'sedang dikerjakan';

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
          const Text('Bukti Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          if (buktiList.isEmpty)
            const Text('Belum ada bukti foto diupload', style: TextStyle(color: AppTheme.textMuted, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buktiList.asMap().entries.map((entry) {
                final bukti = entry.value; // BuktiFotoItem
                final fixedUrl = _fixUrl(bukti.url);
                const ngrokHeaders = {'ngrok-skip-browser-warning': 'true'};

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _FotoViewerScreen(
                            urls: buktiList.map((b) => _fixUrl(b.url)).toList(),
                            initialIndex: entry.key,
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
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.bgCardLight,
                            child: const Icon(Icons.broken_image_outlined, color: AppTheme.textMuted),
                          ),
                        ),
                      ),
                    ),
                    if (bolehHapus)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          // ✅ FIX: kirim bukti.id bukan url
                          onTap: () => _hapusFoto(context, bukti.id),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _FotoViewerScreen extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FotoViewerScreen({required this.urls, required this.initialIndex});

  @override
  State<_FotoViewerScreen> createState() => _FotoViewerScreenState();
}

class _FotoViewerScreenState extends State<_FotoViewerScreen> {
  late PageController _pageController;
  late int _current;
  bool _downloading = false;

  static const _ngrokHeaders = {'ngrok-skip-browser-warning': 'true'};

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _download(String url) async {
    setState(() => _downloading = true);
    try {
      final bytes = await _fetchBytes(url);
      if (bytes == null) throw Exception('Gagal mengunduh foto');

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'kompen_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Foto disimpan: ${file.path}'),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<Uint8List?> _fetchBytes(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      _ngrokHeaders.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      client.close();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 5.0,
                child: Center(
                  child: Image.network(
                    widget.urls[i],
                    headers: _ngrokHeaders,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorBuilder: (_, __, ___) => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text('Gagal memuat foto', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _CircleIconBtn(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${_current + 1} / ${widget.urls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  _downloading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                        )
                      : _CircleIconBtn(icon: Icons.download_rounded, onTap: () => _download(widget.urls[_current])),
                ],
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _current ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _current ? Colors.white : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}