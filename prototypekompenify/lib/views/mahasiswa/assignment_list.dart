import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIREBASE FIRESTORE
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/mahasiswa_model.dart'; // Import model mahasiswamu

class AssignmentListScreen extends StatefulWidget {
  final MahasiswaModel mahasiswa; // Menerima lemparan data mahasiswa aktif

  const AssignmentListScreen({super.key, required this.mahasiswa});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  String _search = '';
  int? _filterJam;

  @override
  Widget build(BuildContext context) {
    // 2. GUNAKAN STREAMBUILDER UNTUK MENGAMBIL DATA ASSIGNMENT SECARA REALTIME
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
      builder: (context, snapshot) {
        // A. Tampilkan loading jika data dari Firebase sedang dijepret
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientBackground(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        // B. Tampung hasil dokumen dari Firestore ke dalam list lokal untuk difilter
        List<DocumentSnapshot> assignmentDocs = snapshot.data?.docs ?? [];

        // Filter 1: Fitur Search pencarian judul atau nama dosen
        if (_search.isNotEmpty) {
          assignmentDocs = assignmentDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String judul = data['judul']?.toString().toLowerCase() ?? '';
            String dosen = data['dosenNama']?.toString().toLowerCase() ?? '';
            return judul.contains(_search.toLowerCase()) || dosen.contains(_search.toLowerCase());
          }).toList();
        }

        // Filter 2: Fitur Filter Jam Kompen
        if (_filterJam != null) {
          assignmentDocs = assignmentDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['jamKompen'] == _filterJam;
          }).toList();
        }

        return GradientBackground(
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Daftar Assignment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${assignmentDocs.length} assignment tersedia', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari assignment...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _FilterChip(label: 'Semua', selected: _filterJam == null, onTap: () => setState(() => _filterJam = null)),
                      ...([2, 3, 4, 6].map((j) => _FilterChip(
                        label: '$j Jam',
                        selected: _filterJam == j,
                        onTap: () => setState(() => _filterJam = _filterJam == j ? null : j),
                      ))),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                child: assignmentDocs.isEmpty
                  ? const EmptyState(icon: Icons.assignment_outlined, title: 'Tidak ada assignment', subtitle: 'Belum ada assignment yang tersedia saat ini')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: assignmentDocs.length,
                      itemBuilder: (ctx, i) {
                        final doc = assignmentDocs[i];
                        final data = doc.data() as Map<String, dynamic>;

                        // Ambil variabel array mahasiswa terdaftar dari Firestore
                        List<dynamic> mahasiswaTerdaftar = data['mahasiswaTerdaftar'] ?? [];
                        int kuota = data['kuotaMahasiswa'] ?? 0;
                        
                        final sudahDaftar = mahasiswaTerdaftar.contains(widget.mahasiswa.id);
                        final isFull = mahasiswaTerdaftar.length >= kuota;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            GestureDetector(
                              onTap: () => _showDetail(context, data),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(data['judul'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('Dosen: ${data['dosenNama'] ?? ''}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                Text('Jam Kompen: ${data['jamKompen'] ?? 0} jam', style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 12),
                              ]),
                            ),
                            sudahDaftar
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 16),
                                    SizedBox(width: 6),
                                    Text('Sudah Terdaftar', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ]),
                                )
                              : isFull
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Center(child: Text('Kuota Penuh', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600, fontSize: 13))),
                                  )
                                : PrimaryButton(
                                    label: 'Kerjakan', 
                                    onTap: () => _pilihAssignment(context, doc.id, data), 
                                    icon: Icons.add_task_rounded
                                  ),
                          ]),
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

  // 3. PROSES PILIH ASSIGNMENT & UPDATE KE FIRESTORE (PENGGANTI DATASERVICE)
  void _pilihAssignment(BuildContext context, String assignmentId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Konfirmasi Kompen'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assignment: ${data['judul']}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Dosen: ${data['dosenNama']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text('Jam Kompen: ${data['jamKompen']} jam', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          const Text('Apakah kamu yakin ingin mengerjakan assignment ini?', style: TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog konfirmasi
              
              // Taruh loading indicator selama transaksi database berjalan
              showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

              try {
                // A. Tambahkan ID mahasiswa ke array 'mahasiswaTerdaftar' di dokumen assignment
                await FirebaseFirestore.instance.collection('assignments').doc(assignmentId).update({
                  'mahasiswaTerdaftar': FieldValue.arrayUnion([widget.mahasiswa.id])
                });

                // B. Buat dokumen pengajuan baru di koleksi 'pengajuan' Firestore
                String idPengajuanBaru = const Uuid().v4();
                await FirebaseFirestore.instance.collection('pengajuan').doc(idPengajuanBaru).set({
                  'id': idPengajuanBaru,
                  'mahasiswaId': widget.mahasiswa.id,
                  'mahasiswaNama': widget.mahasiswa.nama,
                  'mahasiswaNim': widget.mahasiswa.nim,
                  'assignmentId': assignmentId,
                  'assignmentJudul': data['judul'],
                  'dosenId': data['dosenId'],
                  'dosenNama': data['dosenNama'],
                  'jamKompen': data['jamKompen'],
                  'status': 'menunggu', // Status default awal kompen
                  'tanggalPengajuan': Timestamp.now(),
                });

                // C. Kirim Notifikasi ke Dosen bahwa ada mahasiswa yang mendaftar kompennya
                String idNotifDosen = const Uuid().v4();
                await FirebaseFirestore.instance.collection('notifications').doc(idNotifDosen).set({
                  'id': idNotifDosen,
                  'userId': data['dosenId'],
                  'judul': 'Pengajuan Kompen Baru 📥',
                  'pesan': '${widget.mahasiswa.nama} mendaftar untuk assignment "${data['judul']}"',
                  'waktu': Timestamp.now(),
                  'sudahDibaca': false,
                  'tipe': 'kompen',
                  'referensiId': idPengajuanBaru,
                });

                Navigator.pop(context); // Matikan loading indicator
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Assignment berhasil dipilih! Silakan cek menu Kompen Saya.'), backgroundColor: AppTheme.accentGreen),
                );
              } catch (e) {
                Navigator.pop(context); // Matikan loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Gagal memilih assignment: $e'), backgroundColor: AppTheme.accentRed),
                );
              }
            },
            child: const Text('Kerjakan'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    // Penanganan konversi tipe data waktu dari Firestore Timestamp
    DateTime tglMulai = (data['tanggalMulai'] as Timestamp?)?.toDate() ?? DateTime.now();
    DateTime tglBerakhir = (data['tanggalBerakhir'] as Timestamp?)?.toDate() ?? DateTime.now();
    List<dynamic> mhsTerdaftar = data['mahasiswaTerdaftar'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(data['judul'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            InfoRow(icon: Icons.person_outline, label: 'Dosen', value: data['dosenNama'] ?? ''),
            InfoRow(icon: Icons.schedule_outlined, label: 'Jam Kompen', value: '${data['jamKompen'] ?? 0} jam'),
            InfoRow(icon: Icons.people_outline, label: 'Kuota', value: '${mhsTerdaftar.length}/${data['kuotaMahasiswa'] ?? 0} mahasiswa'),
            InfoRow(icon: Icons.calendar_today_outlined, label: 'Mulai', value: DateFormat('dd MMM yyyy').format(tglMulai)),
            InfoRow(icon: Icons.event_outlined, label: 'Berakhir', value: DateFormat('dd MMM yyyy').format(tglBerakhir)),
            const SizedBox(height: 16),
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Text(data['deskripsi'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.6)),
          ]),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }
}