import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

class KompenSayaScreen extends StatelessWidget {
  const KompenSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    // 1. Tambahkan .toString() karena getPengajuan meminta parameter String
    final list = svc.getPengajuan(mahasiswaId: user.id.toString());

    return GradientBackground(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Kompen Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text('${list.length} pengajuan', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          Expanded(
            child: list.isEmpty
              ? const EmptyState(icon: Icons.task_alt_outlined, title: 'Belum ada kompen', subtitle: 'Pilih assignment di tab Assignment untuk mulai')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => KompenCard(pengajuan: list[i], onTap: () => _showDetail(ctx, list[i])),
                ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, PengajuanKompen p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => KompenDetailScreen(pengajuan: p)));
  }
}

class KompenDetailScreen extends StatelessWidget {
  final PengajuanKompen pengajuan;
  const KompenDetailScreen({super.key, required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    // 2. Tambahkan .toString() pada mahasiswaId saat menyaring data terbaru
    final p = svc.getPengajuan(mahasiswaId: pengajuan.mahasiswaId.toString())
        .firstWhere((x) => x.id == pengajuan.id, orElse: () => pengajuan);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kompen'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.statusColor.withOpacity(0.4)),
              ),
              child: Row(children: [
                Icon(_statusIcon(p.status), color: p.statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.statusLabel, style: TextStyle(color: p.statusColor, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(_statusDesc(p.status), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Detail info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Informasi Kompen', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p.assignmentJudul),
                InfoRow(icon: Icons.person_outline, label: 'Dosen', value: p.dosenNama),
                InfoRow(icon: Icons.schedule_outlined, label: 'Jam Kompen', value: '${p.jamKompen} jam'),
                InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal Pengajuan', value: DateFormat('dd MMM yyyy HH:mm').format(p.tanggalPengajuan)),
                if (p.catatanDosen != null) InfoRow(icon: Icons.comment_outlined, label: 'Catatan Dosen', value: p.catatanDosen!),
                if (p.catatanKaprodi != null) InfoRow(icon: Icons.comment_outlined, label: 'Catatan Kaprodi', value: p.catatanKaprodi!),
              ]),
            ),
            const SizedBox(height: 16),

            // TTD Timeline
            _TtdTimeline(pengajuan: p),
            const SizedBox(height: 16),

            // Actions
            if (p.status == KompenStatus.menunggu || p.status == KompenStatus.proses || p.status == KompenStatus.revisi) ...[
              PrimaryButton(
                label: p.buktiFotoPath != null ? 'Ganti Bukti Foto' : 'Upload Bukti Kompen',
                icon: Icons.upload_file_rounded,
                onTap: () => _uploadBukti(context, p),
              ),
              const SizedBox(height: 10),
              if (p.status == KompenStatus.menunggu)
                OutlinedButton.icon(
                  onPressed: () => _cancelKompen(context, p),
                  icon: const Icon(Icons.cancel_outlined, color: AppTheme.accentRed),
                  label: const Text('Batalkan Pengajuan', style: TextStyle(color: AppTheme.accentRed)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.accentRed),
                  ),
                ),
            ],

            if (p.status == KompenStatus.lunas) ...[
              PrimaryButton(
                label: 'Cetak Surat Kompen',
                icon: Icons.print_rounded,
                onTap: () => _cetakSurat(context, p),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  IconData _statusIcon(KompenStatus s) {
    switch (s) {
      case KompenStatus.menunggu: return Icons.hourglass_top_rounded;
      case KompenStatus.proses: return Icons.autorenew_rounded;
      case KompenStatus.revisi: return Icons.edit_note_rounded;
      case KompenStatus.disetujuiDosen: return Icons.verified_rounded;
      case KompenStatus.lunas: return Icons.celebration_rounded;
      case KompenStatus.ditolak: return Icons.cancel_rounded;
    }
  }

  String _statusDesc(KompenStatus s) {
    switch (s) {
      case KompenStatus.menunggu: return 'Upload bukti pengerjaan untuk melanjutkan';
      case KompenStatus.proses: return 'Menunggu verifikasi dari dosen';
      case KompenStatus.revisi: return 'Dosen meminta revisi, upload ulang bukti';
      case KompenStatus.disetujuiDosen: return 'Menunggu persetujuan akhir dari Kaprodi';
      case KompenStatus.lunas: return 'Kompen selesai! Surat siap dicetak';
      case KompenStatus.ditolak: return 'Pengajuan tidak disetujui';
    }
  }

  Future<void> _uploadBukti(BuildContext context, PengajuanKompen p) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    context.read<DataService>().uploadBukti(p.id, picked.path);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Bukti berhasil diupload! Menunggu verifikasi dosen.'), backgroundColor: AppTheme.accentGreen),
      );
    }
  }

  void _cancelKompen(BuildContext context, PengajuanKompen p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Batalkan Kompen?'),
        content: const Text('Pengajuan kompen ini akan dihapus. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () {
              context.read<DataService>().cancelPengajuan(p.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Batalkan', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _cetakSurat(BuildContext context, PengajuanKompen p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Row(children: [Icon(Icons.description_rounded, color: AppTheme.accent), SizedBox(width: 8), Text('Surat Kompen')]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Surat Kompen Digital', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _suratRow('Nama', p.mahasiswaNama),
          _suratRow('NIM', p.mahasiswaNim),
          _suratRow('Kegiatan', p.assignmentJudul),
          _suratRow('Jam', '${p.jamKompen} jam'),
          _suratRow('Pemberi Kompen', p.dosenNama),
          _suratRow('TTD Dosen', p.tanggalTtdDosen != null ? '✅ ${DateFormat('dd/MM/yyyy').format(p.tanggalTtdDosen!)}' : '-'),
          _suratRow('TTD Kaprodi', p.tanggalTtdKaprodi != null ? '✅ ${DateFormat('dd/MM/yyyy').format(p.tanggalTtdKaprodi!)}' : '-'),
          _suratRow('Status', 'LUNAS'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Cetak PDF'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📄 Surat kompen sedang diproses...'), backgroundColor: AppTheme.primary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _suratRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Spacer(flex: 0),
        SizedBox(width: 100, child: Text(k, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
        const Text(': ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _TtdTimeline extends StatelessWidget {
  final PengajuanKompen pengajuan;
  const _TtdTimeline({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Progress TTD', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 16),
        _ttdStep('Upload Bukti', pengajuan.buktiFotoPath != null, 'Bukti pengerjaan kompen'),
        _ttdLine(pengajuan.buktiFotoPath != null),
        _ttdStep('Verifikasi Dosen', pengajuan.ttdDosenBase64 != null, pengajuan.dosenNama,
          date: pengajuan.tanggalTtdDosen),
        _ttdLine(pengajuan.ttdDosenBase64 != null),
        _ttdStep('Persetujuan Kaprodi', pengajuan.ttdKaprodiBase64 != null, 'Persetujuan akhir',
          date: pengajuan.tanggalTtdKaprodi),
      ]),
    );
  }

  Widget _ttdStep(String title, bool done, String sub, {DateTime? date}) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? AppTheme.accentGreen : AppTheme.bgCardLight,
          border: Border.all(color: done ? AppTheme.accentGreen : AppTheme.divider, width: 2),
        ),
        child: Icon(done ? Icons.check_rounded : Icons.radio_button_unchecked, size: 16, color: done ? Colors.white : AppTheme.textMuted),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: done ? AppTheme.textPrimary : AppTheme.textMuted)),
        Text(date != null ? DateFormat('dd MMM yyyy').format(date) : sub,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ])),
    ]);
  }

  Widget _ttdLine(bool done) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(width: 2, height: 16, color: done ? AppTheme.accentGreen.withOpacity(0.5) : AppTheme.divider),
    );
  }
}