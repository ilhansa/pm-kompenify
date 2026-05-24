import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. WAJIB TAMBAHKAN IMPORT INI
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/mahasiswa_model.dart';

class MahasiswaDashboard extends StatelessWidget {
  final MahasiswaModel mahasiswa;

  const MahasiswaDashboard({super.key, required this.mahasiswa});

  @override
  Widget build(BuildContext context) {
    // 2. BUNGKUS DENGAN STREAMBUILDER DI SINI
    return StreamBuilder<DocumentSnapshot>(
      // Memasang listener realtime ke dokumen Firestore berdasarkan ID mahasiswa
      stream: FirebaseFirestore.instance.collection('users').doc(mahasiswa.id).snapshots(),
      builder: (context, snapshot) {
        
        // A. Tampilkan loading spinner jika koneksi awal ke Firebase sedang diproses
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        // B. Jika terjadi error saat mendengarkan data
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Terjadi kesalahan memuat data realtime")),
          );
        }

        // C. Jika data berhasil didapat dan dokumennya eksis di Firestore
        if (snapshot.hasData && snapshot.data!.exists) {
          // Konversi ulang data snapshot terbaru dari Firestore menjadi objek MahasiswaModel
          final dataTerbaru = MahasiswaModel.fromFirestore(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          // Hitung ulang persentase secara dinamis dari dataTerbaru
          double persentase = dataTerbaru.totalJamKompen > 0
              ? (dataTerbaru.totalJamKompen - dataTerbaru.sisaJamKompen) / dataTerbaru.totalJamKompen
              : 1.0;
          
          double pct = persentase.clamp(0.0, 1.0);
          bool isLunas = dataTerbaru.sisaJamKompen == 0;

          // Kembalikan UI utama kamu yang sekarang menggunakan 'dataTerbaru'
          return GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          dataTerbaru.nama.isNotEmpty ? dataTerbaru.nama[0] : 'U', 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)
                        )
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Halo, ${dataTerbaru.nama.split(' ').first}! 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(dataTerbaru.nim, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLunas ? AppTheme.accentGreen.withOpacity(0.15) : AppTheme.accentOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isLunas ? AppTheme.accentGreen.withOpacity(0.3) : AppTheme.accentOrange.withOpacity(0.3)),
                      ),
                      child: Text(isLunas ? '✅ Lunas' : '⏳ ${dataTerbaru.sisaJamKompen} jam lagi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: isLunas ? AppTheme.accentGreen : AppTheme.accentOrange)),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Rekap Card (Menggunakan dataTerbaru)
                  _RekapCard(
                    pct: pct, 
                    totalJamSelesai: dataTerbaru.totalJamKompen - dataTerbaru.sisaJamKompen, 
                    totalJamWajib: dataTerbaru.totalJamKompen
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Row(children: [
                    const Expanded(child: StatCard(
                      label: 'Total Pengajuan',
                      value: '0', 
                      icon: Icons.assignment_outlined,
                      color: AppTheme.accent,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(
                      label: 'Selesai (Lunas)',
                      value: isLunas ? '1' : '0',
                      icon: Icons.check_circle_outline,
                      color: AppTheme.accentGreen,
                    )),
                  ]),
                  const SizedBox(height: 24),

                  // Recent kompen
                  SectionHeader(title: 'Kompen Terbaru', action: 'Lihat Semua', onAction: () {}),
                  const SizedBox(height: 12),
                  
                  const EmptyState(
                    icon: Icons.assignment_outlined, 
                    title: 'Belum ada kompen', 
                    subtitle: 'Pilih assignment untuk mulai mengajukan kompen'
                  )
                ]),
              ),
            ),
          );
        }

        // D. Antisipasi cadangan jika dokumen tidak ditemukan
        return const Scaffold(
          body: Center(child: Text("Data mahasiswa tidak ditemukan.")),
        );
      },
    );
  }
}

// ====================================================================
// WIDGET _REKAPCARD DI BAWAH INI TETAP UTUH (TIDAK PERLU DIUBAH)
// ====================================================================
class _RekapCard extends StatelessWidget {
  final double pct;
  final int totalJamSelesai;
  final int totalJamWajib;

  const _RekapCard({
    required this.pct, 
    required this.totalJamSelesai, 
    required this.totalJamWajib
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Text('Rekap Jam Kompen', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text('${(pct * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$totalJamSelesai Jam', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const Text('sudah diselesaikan', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$totalJamWajib Jam', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
            const Text('total wajib', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ]),
      ]),
    );
  }
}