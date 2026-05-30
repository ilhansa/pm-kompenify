import 'mahasiswa_model.dart';
import 'dosen_model.dart';

// Enum yang disesuaikan dengan role yang ada di Laravel
enum UserRole { admin, mahasiswa, dosen, kaprodi }

class UserModel {
  final int id;
  final String name;
  final String username;
  final UserRole role;
  final MahasiswaModel?
  mahasiswa; // Relasi ke detail data mahasiswa jika role-nya 'mhs'
  final DosenModel? dosen;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.mahasiswa,
    this.dosen,
  });

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

  // Mapper JSON dari REST API Laravel (Authcontroller@getProfile / Authcontroller@login)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      role: _parseRole(json['role']),
      // Jika di dalam JSON terdapat data object 'mahasiswa', maka kita parse ke MahasiswaModel
      mahasiswa: json['mahasiswa'] != null
          ? MahasiswaModel.fromJson(json['mahasiswa'])
          : null,
      dosen: json['dosen'] != null ? DosenModel.fromJson(json['dosen']) : null,
    );
  }
}
