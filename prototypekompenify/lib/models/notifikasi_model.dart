// lib/models/notifikasi_model.dart
// Sesuai response dari NotifikasiController Laravel
// Field: id, user_id, judul, pesan, is_read, created_at

class NotifikasiModel {
  final String id;
  final String userId;
  final String judul;
  final String pesan;
  final bool isRead;
  final DateTime createdAt;

  NotifikasiModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}