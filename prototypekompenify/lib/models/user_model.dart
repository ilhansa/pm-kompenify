import 'mahasiswa_model.dart';
import 'dosen_model.dart';
import 'kaprodi_model.dart';

// Enum yang disesuaikan dengan role yang ada di Laravel
enum UserRole { admin, mahasiswa, dosen, kaprodi }

class UserModel {
  final String id;
  final String name;
  final String username;
  final UserRole role;

  final MahasiswaModel? mahasiswa;
  final DosenModel? dosen;
  final KaprodiModel? kaprodi;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.mahasiswa,
    this.dosen,
    this.kaprodi,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',

      name: json['nama'] ?? '', // Menangkap 'nama' dari Laravel
      username: json['nimNip'] ?? '', // Menangkap 'nimNip' dari Laravel

      role: _parseRole(json['role']),
      mahasiswa: json['mahasiswa'] != null
          ? MahasiswaModel.fromJson(json['mahasiswa'])
          : null,
      dosen: json['dosen'] != null ? DosenModel.fromJson(json['dosen']) : null,
      kaprodi: json['kaprodi'] != null
          ? KaprodiModel.fromJson(json['kaprodi'])
          : null,
    );
  }
  // Fungsi pembantu untuk mengubah String dari database menjadi Enum di Flutter
  static UserRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'mhs':
        return UserRole.mahasiswa;
      case 'dosen':
        return UserRole.dosen;
      case 'kaprodi':
        return UserRole.kaprodi;
      default:
        return UserRole.mahasiswa;
    }
  }
}
