class MahasiswaModel {
  final int id;
  final int userId;
  final String nim;
  final String? prodi;
  final int totalJamKompen;
  final int sisaJamKompen;

  MahasiswaModel({
    required this.id,
    required this.userId,
    required this.nim,
    this.prodi,
    required this.totalJamKompen,
    required this.sisaJamKompen,
  });

  // Fungsi untuk konversi dari JSON database Laravel ke Object Flutter
  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      id: json['id'],
      userId: json['user_id'],
      nim: json['nim'],
      prodi: json['prodi'],
      totalJamKompen: json['total_jam_kompen'] ?? 0,
      sisaJamKompen: json['sisa_jam_kompen'] ?? 0,
    );
  }

  // Fungsi opsional untuk mengubah kembali Object ke JSON jika diperlukan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nim': nim,
      'prodi': prodi,
      'total_jam_kompen': totalJamKompen,
      'sisa_jam_kompen': sisaJamKompen,
    };
  }
}