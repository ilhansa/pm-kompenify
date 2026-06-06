import 'package:flutter/material.dart';

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
  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    final mhs = json['mahasiswa'] as Map<String, dynamic>?;
    final asg = json['assignment'] as Map<String, dynamic>?;

    // ✅ Fix: support foto_url dan file_path, auto-fix localhost → 10.0.2.2
    List<String> fotos = [];
    if (json['bukti'] != null && json['bukti'] is List) {
      const baseStorageUrl = 'http://10.0.2.2:8000/storage/';
      fotos = (json['bukti'] as List)
          .map((b) {
            if (b['foto_url'] != null && b['foto_url'].toString().isNotEmpty) {
              return b['foto_url']
                  .toString()
                  .replaceAll('http://localhost', 'http://10.0.2.2:8000')
                  .replaceAll('http://127.0.0.1', 'http://10.0.2.2:8000');
            } else if (b['file_path'] != null && b['file_path'].toString().isNotEmpty) {
              return '$baseStorageUrl${b['file_path']}';
            }
            return '';
          })
          .where((u) => u.isNotEmpty)
          .toList();
    }

    return PengajuanModel(
      id:           json['id']?.toString() ?? '',
      mahasiswaId:  json['mahasiswa_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      status:       json['status']?.toString() ?? 'pending',
      createdAt:    json['created_at']?.toString() ?? '',
      mahasiswaNim:        mhs?['nim']?.toString(),
      mahasiswaNama:       mhs != null ? _getNama(mhs) : null,
      assignmentJudul:     asg?['judul']?.toString(),
      assignmentJamKompen: asg?['jam_kompen'] is int
          ? asg!['jam_kompen'] as int
          : int.tryParse(asg?['jam_kompen']?.toString() ?? ''),
      assignmentDosenId: asg?['dosen_id']?.toString(),
      buktiFotos: fotos,
    );
  }

  static String? _getNama(Map<String, dynamic> mhs) {
    final user = mhs['user'] as Map<String, dynamic>?;
    return user?['nama']?.toString();
  }

  Color get statusColor {
    switch (status) {
      case 'diterima':            return const Color(0xFF4CAF8D);
      case 'ditolak':             return const Color(0xFFE74C6B);
      case 'menunggu_verifikasi': return const Color(0xFF6C63FF);
      default:                    return const Color(0xFFFFB020);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'diterima':            return 'Diterima';
      case 'ditolak':             return 'Ditolak';
      case 'menunggu_verifikasi': return 'Menunggu Verifikasi';
      default:                    return 'Pending';
    }
  }
}