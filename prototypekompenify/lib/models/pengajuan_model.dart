import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PengajuanModel {
  final String id;
  final String mahasiswaId;
  final String assignmentId;
  final String status;
  final String createdAt;

  final String? mahasiswaNim;
  final String? mahasiswaNama;
  final String? assignmentJudul;
  final int? assignmentJamKompen;
  final String? assignmentDosenId;
  final List<String> buktiFotos;

  // 🚀 SAKTI: Tambahkan dua variabel penampung hash QR dari Laravel
  final String? qrTokenDosen;
  final String? qrTokenKaprodi;

  PengajuanModel({
    required this.id,
    required this.mahasiswaId,
    required this.assignmentId,
    required this.status,
    required this.createdAt,
    this.mahasiswaNim,
    this.mahasiswaNama,
    this.assignmentJudul,
    this.assignmentJamKompen,
    this.assignmentDosenId,
    this.buktiFotos = const [],
    this.qrTokenDosen, // Masukkan ke constructor
    this.qrTokenKaprodi, // Masukkan ke constructor
  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    final mhs = json['mahasiswa'] as Map<String, dynamic>?;
    final asg = json['assignment'] as Map<String, dynamic>?;

    // Sinkronisasi URL Foto Bukti dengan Link Ngrok aktif secara dinamis
    List<String> fotos = [];
    if (json['bukti'] != null && json['bukti'] is List) {
      final envUrl =
          dotenv.env['BASE_URL']?.replaceAll('/api', '') ??
          'http://10.0.2.2:8000';
      final baseStorageUrl = '$envUrl/storage/';

      fotos = (json['bukti'] as List)
          .map((b) {
            if (b['foto_url'] != null && b['foto_url'].toString().isNotEmpty) {
              return b['foto_url']
                  .toString()
                  .replaceAll('http://localhost:8000', envUrl)
                  .replaceAll('http://localhost', envUrl)
                  .replaceAll('http://127.0.0.1:8000', envUrl)
                  .replaceAll('http://127.0.0.1', envUrl)
                  .replaceAll('http://10.0.2.2:8000', envUrl);
            } else if (b['file_path'] != null &&
                b['file_path'].toString().isNotEmpty) {
              return '$baseStorageUrl${b['file_path']}';
            }
            return '';
          })
          .where((u) => u.isNotEmpty)
          .toList();
    }

    return PengajuanModel(
      id: json['id']?.toString() ?? '',
      mahasiswaId: json['mahasiswa_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      mahasiswaNim: mhs?['nim']?.toString(),
      mahasiswaNama: mhs != null ? _getNama(mhs) : null,
      assignmentJudul: asg?['judul']?.toString(),
      assignmentJamKompen: asg?['jam_kompen'] is int
          ? asg!['jam_kompen'] as int
          : int.tryParse(asg?['jam_kompen']?.toString() ?? ''),
      assignmentDosenId: asg?['dosen_id']?.toString(),
      buktiFotos: fotos,

      // 🚀 MAPPING BARU: Ambil data token dari response database terupdate
      qrTokenDosen: json['qr_token_dosen']?.toString(),
      qrTokenKaprodi: json['qr_token_kaprodi']?.toString(),
    );
  }

  // Fallback Mapping Nama: Mengatasi variasi perubahan struktur JSON dari Backend
  static String? _getNama(Map<String, dynamic> mhs) {
    final user = mhs['user'] as Map<String, dynamic>?;
    if (user != null && user['nama'] != null) {
      return user['nama']?.toString();
    }
    if (mhs['nama'] != null) {
      return mhs['nama']?.toString();
    }
    if (mhs['nama_mahasiswa'] != null) {
      return mhs['nama_mahasiswa']?.toString();
    }
    return null;
  }

  // 🚀 MEROMBAK WARNA BADGE STATUS BIAR COCOK SAMA TAHAPAN WORKFLOW BARU
  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFB020); // Oranye (Butuh Persetujuan)
      case 'menunggu_ttd_dosen':
        return const Color(0xFF6C63FF); // Ungu (Proses Dosen)
      case 'menunggu_ttd_kaprodi':
        return const Color(0xFF00B4D8); // Biru Muda (Proses Kaprodi)
      case 'diterima':
        return const Color(0xFF4CAF8D); // Hijau (Selesai Semuanya)
      case 'ditolak':
        return const Color(0xFFE74C6B); // Merah
      default:
        return const Color(0xFFFFB020);
    }
  }

  // 🚀 MEROMBAK LABEL TEKS DI UI SESUAI ALUR BERJENJANG KAMU
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'menunggu_ttd_dosen':
        return 'Menunggu TTD Dosen';
      case 'menunggu_ttd_kaprodi':
        return 'Menunggu TTD Kaprodi';
      case 'diterima':
        return 'Diterima / Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }
}
