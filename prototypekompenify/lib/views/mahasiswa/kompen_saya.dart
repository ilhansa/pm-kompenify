import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIREBASE
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/mahasiswa_model.dart'; // Import model mahasiswamu

enum KompenStatus { menunggu, proses, revisi, disetujuiDosen, lunas, ditolak }

class KompenSayaScreen extends StatefulWidget {
  final MahasiswaModel mahasiswa;

  const KompenSayaScreen({super.key, required this.mahasiswa});

  @override
  State<KompenSayaScreen> createState() => _KompenSayaScreenState();
}

class _KompenSayaScreenState extends State<KompenSayaScreen> {
  @override
  Widget build(BuildContext context) {
    // 2. STREAMBUILDER UNTUK MENGAMBIL DAFTAR PENGAJUAN MAHASISWA AKTIF
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengajuan')
          .where('mahasiswaId', isEqualTo: widget.mahasiswa.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientBackground(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        final documents = snapshot.data?.docs ?? [];

        return GradientBackground(
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Kompen Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('${documents.length} pengajuan', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ),
              Expanded(
                child: documents.isEmpty
                  ? const EmptyState(icon: Icons.task_alt_outlined, title: 'Belum ada kompen', subtitle: 'Pilih assignment di tab Assignment untuk mulai')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: documents.length,
                      itemBuilder: (ctx, i) {
                        final data = documents[i].data() as Map<String, dynamic>;
                        return KompenCard(
                          pengajuan: data, 
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => KompenDetailScreen(pengajuanId: data['id']))
                          )
                        );
                      },
                    ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class KompenDetailScreen extends StatelessWidget {
  final String pengajuanId;

  const KompenDetailScreen({super.key, required this.pengajuanId});

  @override
  Widget build(BuildContext context) {
    // 3. STREAMBUILDER UNTUK DETAIL SINGLE DOKUMEN REALTIME
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('pengajuan').doc(pengajuanId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.bgDark,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
        }

        final p = snapshot.data!.data() as Map<String, dynamic>;

        // Parsing data status dari string ke format enum lokal
        String statusStr = p['status'] ?? 'menunggu';
        KompenStatus currentStatus = KompenStatus.values.byName(statusStr);

        DateTime tglPengajuan = (p['tanggalPengajuan'] as Timestamp?)?.toDate() ?? DateTime.now();
        DateTime? tglTtdDosen = (p['tanggalTtdDosen'] as Timestamp?)?.toDate();
        DateTime? tglTtdKaprodi = (p['tanggalTtdKaprodi'] as Timestamp?)?.toDate();

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
                    color: _statusColor(currentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor(currentStatus).withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(_statusIcon(currentStatus), color: _statusColor(currentStatus), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_statusLabel(currentStatus), style: TextStyle(color: _statusColor(currentStatus), fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(_statusDesc(currentStatus), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
                    InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p['assignmentJudul'] ?? ''),
                    InfoRow(icon: Icons.person_outline, label: 'Dosen', value: p['dosenNama'] ?? ''),
                    InfoRow(icon: Icons.schedule_outlined, label: 'Jam Kompen', value: '${p['jamKompen'] ?? 0} jam'),
                    InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal Pengajuan', value: DateFormat('dd MMM yyyy HH:mm').format(tglPengajuan)),
                    if (p['catatanDosen'] != null) InfoRow(icon: Icons.comment_outlined, label: 'Catatan Dosen', value: p['catatanDosen']),
                    if (p['catatanKaprodi'] != null) InfoRow(icon: Icons.comment_outlined, label: 'Catatan Kaprodi', value: p['catatanKaprodi']),
                  ]),
                ),
                const SizedBox(height: 16),

                // TTD Timeline
                _TtdTimeline(p: p, status: currentStatus, tglTtdDosen: tglTtdDosen, tglTtdKaprodi: tglTtdKaprodi),
                const SizedBox(height: 16),

                // Actions
                if (currentStatus == KompenStatus.menunggu || currentStatus == KompenStatus.proses || currentStatus == KompenStatus.revisi) ...[
                  PrimaryButton(
                    label: p['buktiFotoPath'] != null ? 'Ganti Bukti Foto' : 'Upload Bukti Kompen',
                    icon: Icons.upload_file_rounded,
                    onTap: () => _uploadBukti(context, pengajuanId),
                  ),
                  const SizedBox(height: 10),
                  if (currentStatus == KompenStatus.menunggu)
                    OutlinedButton.icon(
                      onPressed: () => _cancelKompen(context, pengajuanId, p['assignmentId'], p['mahasiswaId']),
                      icon: const Icon(Icons.cancel_outlined, color: AppTheme.accentRed),
                      label: const Text('Batalkan Pengajuan', style: TextStyle(color: AppTheme.accentRed)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppTheme.accentRed),
                      ),
                    ),
                ],

                if (currentStatus == KompenStatus.lunas) ...[
                  PrimaryButton(
                    label: 'Cetak Surat Kompen',
                    icon: Icons.print_rounded,
                    onTap: () => _cetakSurat(context, p, tglTtdDosen, tglTtdKaprodi),
                  ),
                ],
              ]),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(KompenStatus s) {
    switch (s) {
      case KompenStatus.menunggu: return AppTheme.textSecondary;
      case KompenStatus.proses: return AppTheme.accentOrange;
      case KompenStatus.revisi: return AppTheme.accentRed;
      case KompenStatus.disetujuiDosen: return AppTheme.accent;
      case KompenStatus.lunas: return AppTheme.accentGreen;
      case KompenStatus.ditolak: return AppTheme.accentRed;
    }
  }

  String _statusLabel(KompenStatus s) {
    switch (s) {
      case KompenStatus.menunggu: return 'Menunggu Bukti';
      case KompenStatus.proses: return 'Sedang Diproses';
      case KompenStatus.revisi: return 'Perlu Revisi';
      case KompenStatus.disetujuiDosen: return 'Disetujui Dosen';
      case KompenStatus.lunas: return 'Lunas / Selesai';
      case KompenStatus.ditolak: return 'Ditolak';
    }
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

  // 4. LOGIKA UPDATE FIRESTORE SAAT UPLOAD BUKTI FOTO
  Future<void> _uploadBukti(BuildContext context, String id) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseFirestore.instance.collection('pengajuan').doc(id).update({
        'buktiFotoPath': picked.path,
        'status': 'proses', // Otomatis naik kelas ke status 'proses' verifikasi dosen
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Bukti berhasil diupload! Menunggu verifikasi dosen.'), backgroundColor: AppTheme.accentGreen),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Gagal upload bukti: $e')));
    }
  }

  // 5. LOGIKA PEMBATALAN PENGAJUAN (HAPUS DOKUMEN & KELUARKAN MAHASISWA DARI KUOTA ASSIGNMENT)
  void _cancelKompen(BuildContext context, String id, String asgId, String mhsId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Batalkan Kompen?'),
        content: const Text('Pengajuan kompen ini akan dihapus. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

              try {
                // Hapus nama mahasiswa dari array 'mahasiswaTerdaftar' di dokumen assignment agar kuotanya berkurang lagi
                await FirebaseFirestore.instance.collection('assignments').doc(asgId).update({
                  'mahasiswaTerdaftar': FieldValue.arrayRemove([mhsId])
                });

                // Hapus dokumen pengajuannya dari Firestore
                await FirebaseFirestore.instance.collection('pengajuan').doc(id).delete();
                
                Navigator.pop(context); // Tutup loading
                Navigator.pop(context); // Mundur kembali ke screen Kompen Saya
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Gagal membatalkan: $e')));
              }
            },
            child: const Text('Batalkan', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _cetakSurat(BuildContext context, Map<String, dynamic> p, DateTime? ttdDosen, DateTime? ttdKaprodi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Row(children: [Icon(Icons.description_rounded, color: AppTheme.accent), SizedBox(width: 8), Text('Surat Kompen')]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Surat Kompen Digital', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _suratRow('Nama', p['mahasiswaNama'] ?? ''),
          _suratRow('NIM', p['mahasiswaNim'] ?? ''),
          _suratRow('Kegiatan', p['assignmentJudul'] ?? ''),
          _suratRow('Jam', '${p['jamKompen'] ?? 0} jam'),
          _suratRow('Pemberi Kompen', p['dosenNama'] ?? ''),
          _suratRow('TTD Dosen', ttdDosen != null ? '✅ ${DateFormat('dd/MM/yyyy').format(ttdDosen)}' : '-'),
          _suratRow('TTD Kaprodi', ttdKaprodi != null ? '✅ ${DateFormat('dd/MM/yyyy').format(ttdKaprodi)}' : '-'),
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

  static Widget _suratRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(k, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
        const Text(': ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _TtdTimeline extends StatelessWidget {
  final Map<String, dynamic> p;
  final KompenStatus status;
  final DateTime? tglTtdDosen;
  final DateTime? tglTtdKaprodi;

  const _TtdTimeline({
    required this.p, 
    required this.status, 
    this.tglTtdDosen, 
    this.tglTtdKaprodi
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Progress TTD', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 16),
        _ttdStep('Upload Bukti', p['buktiFotoPath'] != null, 'Bukti pengerjaan kompen'),
        _ttdLine(p['buktiFotoPath'] != null),
        _ttdStep('Verifikasi Dosen', p['ttdDosenBase64'] != null, p['dosenNama'] ?? '', date: tglTtdDosen),
        _ttdLine(p['ttdDosenBase64'] != null),
        _ttdStep('Persetujuan Kaprodi', p['ttdKaprodiBase64'] != null, 'Persetujuan akhir', date: tglTtdKaprodi),
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
        Text(date != null ? DateFormat('dd MMM yyyy').format(date) : sub, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
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