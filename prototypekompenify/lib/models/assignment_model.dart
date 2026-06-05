// lib/models/assignment_model.dart
// ✅ Update: tambah field dosenNama (dari relasi with('dosen'))

class AssignmentModel {
  final String id;
  final String judul;
  final String deskripsi;
  final int jamKompen;
  final String dosenId;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String status;
  final String? dosenNama; // dari relasi with('dosen:id,nama') di Laravel

  AssignmentModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.jamKompen,
    required this.dosenId,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    this.dosenNama,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    // Ambil nama dosen dari relasi (kalau ada)
    String? namaDosen;
    if (json['dosen'] != null && json['dosen'] is Map) {
      namaDosen = json['dosen']['nama'];
    }

    return AssignmentModel(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jamKompen: json['jam_kompen'] ?? 0,
      dosenId: json['dosen_id'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      status: json['status'] ?? 'aktif',
      dosenNama: namaDosen,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'deskripsi': deskripsi,
    'jam_kompen': jamKompen,
    'dosen_id': dosenId,
    'tanggal_mulai': tanggalMulai,
    'tanggal_selesai': tanggalSelesai,
    'status': status,
  };
}