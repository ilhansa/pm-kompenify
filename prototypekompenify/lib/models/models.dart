import 'package:flutter/material.dart';

enum UserRole { admin, mahasiswa, dosen, kaprodi }
enum KompenStatus { menunggu, proses, revisi, disetujuiDosen, lunas, ditolak }
enum AssignmentStatus { tersedia, penuh, ditutup }

class User {
  final String id;
  final String nim; // NIM/NIP
  final String nama;
  final UserRole role;
  final String? prodi;
  final String? email;
  String? signatureBase64;

  User({
    required this.id,
    required this.nim,
    required this.nama,
    required this.role,
    this.prodi,
    this.email,
    this.signatureBase64,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.admin: return 'Admin';
      case UserRole.mahasiswa: return 'Mahasiswa';
      case UserRole.dosen: return 'Dosen';
      case UserRole.kaprodi: return 'Kaprodi';
    }
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nim: map['nim'],
      nama: map['nama'],
      role: UserRole.values.firstWhere((r) => r.name == map['role']),
      prodi: map['prodi'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'nim': nim, 'nama': nama,
    'role': role.name, 'prodi': prodi, 'email': email,
  };
}

class Assignment {
  final String id;
  final String judul;
  final String deskripsi;
  final int jamKompen;
  final String dosenId;
  final String dosenNama;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final int kuotaMahasiswa;
  final List<String> mahasiswaTerdaftar;
  AssignmentStatus status;

  Assignment({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.jamKompen,
    required this.dosenId,
    required this.dosenNama,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.kuotaMahasiswa,
    this.mahasiswaTerdaftar = const [],
    this.status = AssignmentStatus.tersedia,
  });

  bool get isFull => mahasiswaTerdaftar.length >= kuotaMahasiswa;
  int get sisaKuota => kuotaMahasiswa - mahasiswaTerdaftar.length;
}

class PengajuanKompen {
  final String id;
  final String mahasiswaId;
  final String mahasiswaNama;
  final String mahasiswaNim;
  final String assignmentId;
  final String assignmentJudul;
  final String dosenId;
  final String dosenNama;
  final int jamKompen;
  KompenStatus status;
  final DateTime tanggalPengajuan;
  DateTime? tanggalVerifikasi;
  String? buktiFotoPath;
  String? catatanDosen;
  String? catatanKaprodi;
  String? ttdDosenBase64;
  String? ttdKaprodiBase64;
  DateTime? tanggalTtdDosen;
  DateTime? tanggalTtdKaprodi;

  PengajuanKompen({
    required this.id,
    required this.mahasiswaId,
    required this.mahasiswaNama,
    required this.mahasiswaNim,
    required this.assignmentId,
    required this.assignmentJudul,
    required this.dosenId,
    required this.dosenNama,
    required this.jamKompen,
    this.status = KompenStatus.menunggu,
    required this.tanggalPengajuan,
    this.tanggalVerifikasi,
    this.buktiFotoPath,
    this.catatanDosen,
    this.catatanKaprodi,
    this.ttdDosenBase64,
    this.ttdKaprodiBase64,
    this.tanggalTtdDosen,
    this.tanggalTtdKaprodi,
  });

  String get statusLabel {
    switch (status) {
      case KompenStatus.menunggu: return 'Menunggu';
      case KompenStatus.proses: return 'Dalam Proses';
      case KompenStatus.revisi: return 'Perlu Revisi';
      case KompenStatus.disetujuiDosen: return 'Disetujui Dosen';
      case KompenStatus.lunas: return 'Lunas';
      case KompenStatus.ditolak: return 'Ditolak';
    }
  }

  Color get statusColor {
    switch (status) {
      case KompenStatus.menunggu: return const Color(0xFFFFB020);
      case KompenStatus.proses: return const Color(0xFF7B5CE8);
      case KompenStatus.revisi: return const Color(0xFFFF7043);
      case KompenStatus.disetujuiDosen: return const Color(0xFF2196F3);
      case KompenStatus.lunas: return const Color(0xFF4CAF8D);
      case KompenStatus.ditolak: return const Color(0xFFE74C6B);
    }
  }
}

class Notifikasi {
  final String id;
  final String userId;
  final String judul;
  final String pesan;
  final DateTime waktu;
  bool sudahDibaca;
  final String? referensiId;
  final String tipe; // 'assignment', 'kompen', 'ttd', 'approval'

  Notifikasi({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.sudahDibaca = false,
    this.referensiId,
    required this.tipe,
  });
}

class RekapKompen {
  final String mahasiswaId;
  final String mahasiswaNama;
  final int totalJamWajib;
  final int totalJamSelesai;

  RekapKompen({
    required this.mahasiswaId,
    required this.mahasiswaNama,
    required this.totalJamWajib,
    required this.totalJamSelesai,
  });

  int get sisaJam => totalJamWajib - totalJamSelesai;
  double get persentase => totalJamWajib > 0 ? (totalJamSelesai / totalJamWajib) : 0;
  bool get sudahLunas => sisaJam <= 0;
}