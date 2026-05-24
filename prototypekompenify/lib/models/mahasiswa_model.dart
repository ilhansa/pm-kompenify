import 'user_model.dart';

class MahasiswaModel extends User {
  // Variabel spesifik milik mahasiswa
  final int totalJamKompen;
  final int sisaJamKompen;

  MahasiswaModel({
    required super.id,
    required String nim, // Menerima input sebagai 'nim'
    required super.password,
    required super.nama,
    required super.role,
    required this.totalJamKompen,
    required this.sisaJamKompen,
  }) : super(nimNip: nim); // Nilai 'nim' dilempar ke 'nimNip' milik kelas induk

  String get userId => id;
  
  String get nim => nimNip;

  // factory untuk mengubah data JSON Firebase Firestore menjadi objek MahasiswaModel
  factory MahasiswaModel.fromFirestore(String docId, Map<String, dynamic> json) {
    // Ambil teks string dari Firebase, jika kosong default ke 'mahasiswa'
    String roleString = json['role'] ?? 'mahasiswa';

    return MahasiswaModel(
      id: docId,
      nim: json['nim_nip'] ?? '', // Di database diseragamkan pakai nama 'nim_nip'
      password: json['password'] ?? '',
      nama: json['nama'] ?? '',
      role: UserRole.values.byName(json['role'] ?? 'mahasiswa'),
      totalJamKompen: json['total_jam_kompen'] ?? 0, 
      sisaJamKompen: json['sisa_jam_kompen'] ?? 0,
    );
  }

// (Enum -> String)
  Map<String, dynamic> toJson() {
    return {
      'nim_nip': nim,
      'password': password,
      'nama': nama,
      'role': role.name, // .name akan mengubah UserRole.mahasiswa menjadi teks "mahasiswa"
      'total_jam_kompen': totalJamKompen,
      'sisa_jam_kompen': sisaJamKompen,
    };
  }
}