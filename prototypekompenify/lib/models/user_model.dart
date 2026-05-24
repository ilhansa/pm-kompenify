enum UserRole { admin, mahasiswa, dosen, kaprodi }

class User {
  final String id;
  final String nimNip; // NIM (mahasiswa) atau NIP (dosen/admin)
  final String password;
  final String nama;
  final UserRole role;

  User({
    required this.id,
    required this.nimNip,
    required this.password,
    required this.nama,
    required this.role,
  });
}