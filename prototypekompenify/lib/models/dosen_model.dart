import 'user_model.dart';

class DosenModel extends User {
  // Variabel spesifik milik dosen sesuai data Firestore kamu
  final String tandaTanganPath;

  DosenModel({
    required super.id,
    required String nip, 
    required super.password,
    required super.nama,
    required super.role,
    required this.tandaTanganPath,
  }) : super(nimNip: nip); // Melempar nilai NIP ke properti induk nimNip

  String get userId => id;
  String get nip => nimNip;

  // Factory untuk mengubah dokumen JSON Firestore menjadi objek DosenModel
  factory DosenModel.fromFirestore(String docId, Map<String, dynamic> json) {
    return DosenModel(
      id: docId,
      nip: json['nim_nip'] ?? '', // Di Firestore diseragamkan pakai key 'nim_nip'
      password: json['password'] ?? '',
      nama: json['nama'] ?? '',
      role: UserRole.values.byName(json['role'] ?? 'dosen'),
      tandaTanganPath: json['tandaTanganPath'] ?? '',
    );
  }

  // Mengubah objek Model menjadi JSON jika dosen ingin update tanda tangan
  Map<String, dynamic> toJson() {
    return {
      'nim_nip': nip,
      'password': password,
      'nama': nama,
      'role': role.name,
      'tandaTanganPath': tandaTanganPath,
    };
  }
}