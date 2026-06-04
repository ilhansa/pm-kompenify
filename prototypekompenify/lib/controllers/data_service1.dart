import 'package:flutter/foundation.dart';
import '../models/models.dart';

class DataService1 extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Mock data
  final List<User> _users = [
    User(id: 'a1', nim: 'ADMIN001', nama: 'Administrator', role: UserRole.admin),
    User(id: 'm1', nim: '244107060072', nama: 'Ilhan Salih Ilmansyah', role: UserRole.mahasiswa, prodi: 'Sistem Informasi Bisnis'),
    User(id: 'm2', nim: '244107060022', nama: 'Krisna Aditya Satria', role: UserRole.mahasiswa, prodi: 'Sistem Informasi Bisnis'),
    User(id: 'm3', nim: '244107060132', nama: 'Muhammad Naufal', role: UserRole.mahasiswa, prodi: 'Sistem Informasi Bisnis'),
    User(id: 'd1', nim: 'NIP001', nama: 'Vivin Ayu Lestari, S.Pd., M.Kom.', role: UserRole.dosen, prodi: 'Sistem Informasi Bisnis'),
    User(id: 'd2', nim: 'NIP002', nama: 'Budi Santoso, M.T.', role: UserRole.dosen, prodi: 'Teknologi Informasi'),
    User(id: 'k1', nim: 'KAPRODI01', nama: 'Dr. Ahmad Fauzi, M.Kom.', role: UserRole.kaprodi, prodi: 'Sistem Informasi Bisnis'),
  ];

  final List<Assignment> _assignments = [];
  final List<PengajuanKompen> _pengajuan = [];
  final List<Notifikasi> _notifikasi = [];

  DataService() {
    _initSampleData();
  }

  void _initSampleData() {
    final now = DateTime.now();

    _assignments.addAll([
      Assignment(
        id: 'asg1',
        judul: 'Membuat Laporan Praktikum Jaringan',
        deskripsi: 'Mahasiswa diminta membuat laporan lengkap praktikum jaringan komputer mencakup topologi, konfigurasi, dan analisis.',
        jamKompen: 3,
        dosenId: 'd1',
        dosenNama: 'Vivin Ayu Lestari, S.Pd., M.Kom.',
        tanggalMulai: now.subtract(const Duration(days: 2)),
        tanggalBerakhir: now.add(const Duration(days: 5)),
        kuotaMahasiswa: 5,
        mahasiswaTerdaftar: ['m3'],
      ),
      Assignment(
        id: 'asg2',
        judul: 'Membantu Kegiatan Seminar Prodi',
        deskripsi: 'Membantu persiapan dan pelaksanaan seminar program studi sebagai panitia.',
        jamKompen: 4,
        dosenId: 'd1',
        dosenNama: 'Vivin Ayu Lestari, S.Pd., M.Kom.',
        tanggalMulai: now,
        tanggalBerakhir: now.add(const Duration(days: 3)),
        kuotaMahasiswa: 10,
        mahasiswaTerdaftar: [],
      ),
      Assignment(
        id: 'asg3',
        judul: 'Input Data Administrasi Jurusan',
        deskripsi: 'Membantu staf administrasi dalam menginput data mahasiswa ke sistem akademik.',
        jamKompen: 2,
        dosenId: 'd2',
        dosenNama: 'Budi Santoso, M.T.',
        tanggalMulai: now.subtract(const Duration(days: 1)),
        tanggalBerakhir: now.add(const Duration(days: 7)),
        kuotaMahasiswa: 3,
        mahasiswaTerdaftar: ['m1', 'm2'],
      ),
    ]);

    _pengajuan.addAll([
      PengajuanKompen(
        id: 'p1',
        mahasiswaId: 'm1',
        mahasiswaNama: 'Ilhan Salih Ilmansyah',
        mahasiswaNim: '244107060072',
        assignmentId: 'asg3',
        assignmentJudul: 'Input Data Administrasi Jurusan',
        dosenId: 'd2',
        dosenNama: 'Budi Santoso, M.T.',
        jamKompen: 2,
        status: KompenStatus.disetujuiDosen,
        tanggalPengajuan: now.subtract(const Duration(days: 3)),
        buktiFotoPath: 'mock_foto.jpg',
        tanggalTtdDosen: now.subtract(const Duration(days: 1)),
      ),
      PengajuanKompen(
        id: 'p2',
        mahasiswaId: 'm1',
        mahasiswaNama: 'Ilhan Salih Ilmansyah',
        mahasiswaNim: '244107060072',
        assignmentId: 'asg1',
        assignmentJudul: 'Membuat Laporan Praktikum Jaringan',
        dosenId: 'd1',
        dosenNama: 'Vivin Ayu Lestari, S.Pd., M.Kom.',
        jamKompen: 3,
        status: KompenStatus.menunggu,
        tanggalPengajuan: now.subtract(const Duration(hours: 5)),
      ),
    ]);

    _notifikasi.addAll([
      Notifikasi(
        id: 'n1',
        userId: 'm1',
        judul: 'Assignment Baru Tersedia',
        pesan: 'Dosen Budi Santoso membuat assignment baru: Input Data Administrasi Jurusan (2 jam)',
        waktu: now.subtract(const Duration(days: 3)),
        sudahDibaca: true,
        tipe: 'assignment',
        referensiId: 'asg3',
      ),
      Notifikasi(
        id: 'n2',
        userId: 'm1',
        judul: 'TTD Dosen Diterima! 🎉',
        pesan: 'Kompen "Input Data Administrasi Jurusan" telah ditandatangani oleh Budi Santoso. Menunggu persetujuan Kaprodi.',
        waktu: now.subtract(const Duration(days: 1)),
        sudahDibaca: false,
        tipe: 'ttd',
        referensiId: 'p1',
      ),
      Notifikasi(
        id: 'n3',
        userId: 'k1',
        judul: 'Kompen Menunggu Persetujuan',
        pesan: 'Ilhan Salih Ilmansyah mengajukan kompen yang sudah disetujui dosen. Silakan review dan berikan TTD.',
        waktu: now.subtract(const Duration(days: 1)),
        sudahDibaca: false,
        tipe: 'approval',
        referensiId: 'p1',
      ),
      Notifikasi(
        id: 'n4',
        userId: 'd1',
        judul: 'Mahasiswa Upload Bukti Kompen',
        pesan: 'Muhammad Naufal telah mengupload bukti pengerjaan assignment "Membuat Laporan Praktikum Jaringan".',
        waktu: now.subtract(const Duration(hours: 2)),
        sudahDibaca: false,
        tipe: 'kompen',
        referensiId: 'p2',
      ),
    ]);
  }

  // Auth
  bool login(String nim, String password) {
    final user = _users.firstWhere(
      (u) => u.nim == nim,
      orElse: () => User(id: '', nim: '', nama: '', role: UserRole.mahasiswa),
    );
    if (user.id.isEmpty) return false;
    // Mock: password = 'password123' for all
    if (password != 'password123') return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Users
  List<User> getUsers({UserRole? role}) {
    if (role == null) return List.from(_users);
    return _users.where((u) => u.role == role).toList();
  }

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(User user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) { _users[idx] = user; notifyListeners(); }
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  // Assignments
  List<Assignment> getAssignments({String? dosenId, bool availableOnly = false}) {
    var list = List<Assignment>.from(_assignments);
    if (dosenId != null) list = list.where((a) => a.dosenId == dosenId).toList();
    if (availableOnly) list = list.where((a) => a.status == AssignmentStatus.tersedia && !a.isFull).toList();
    return list;
  }

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    // Notify all mahasiswa
    for (var u in _users.where((u) => u.role == UserRole.mahasiswa)) {
      _notifikasi.add(Notifikasi(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}_${u.id}',
        userId: u.id,
        judul: 'Assignment Baru Tersedia! 📋',
        pesan: '${assignment.dosenNama} membuat assignment: ${assignment.judul} (${assignment.jamKompen} jam)',
        waktu: DateTime.now(),
        tipe: 'assignment',
        referensiId: assignment.id,
      ));
    }
    notifyListeners();
  }

  void updateAssignment(Assignment assignment) {
    final idx = _assignments.indexWhere((a) => a.id == assignment.id);
    if (idx >= 0) { _assignments[idx] = assignment; notifyListeners(); }
  }

  void deleteAssignment(String id) {
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  bool pilihAssignment(String assignmentId, String mahasiswaId) {
    final idx = _assignments.indexWhere((a) => a.id == assignmentId);
    if (idx < 0 || _assignments[idx].isFull) return false;
    if (_assignments[idx].mahasiswaTerdaftar.contains(mahasiswaId)) return false;
    _assignments[idx].mahasiswaTerdaftar.add(mahasiswaId);
    notifyListeners();
    return true;
  }

  // Pengajuan
  List<PengajuanKompen> getPengajuan({String? mahasiswaId, String? dosenId, KompenStatus? status}) {
    var list = List<PengajuanKompen>.from(_pengajuan);
    if (mahasiswaId != null) list = list.where((p) => p.mahasiswaId == mahasiswaId).toList();
    if (dosenId != null) list = list.where((p) => p.dosenId == dosenId).toList();
    if (status != null) list = list.where((p) => p.status == status).toList();
    return list;
  }

  void addPengajuan(PengajuanKompen pengajuan) {
    _pengajuan.add(pengajuan);
    // Notify dosen
    _notifikasi.add(Notifikasi(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      userId: pengajuan.dosenId,
      judul: 'Pengajuan Kompen Baru',
      pesan: '${pengajuan.mahasiswaNama} mengajukan kompen untuk "${pengajuan.assignmentJudul}"',
      waktu: DateTime.now(),
      tipe: 'kompen',
      referensiId: pengajuan.id,
    ));
    notifyListeners();
  }

  void uploadBukti(String pengajuanId, String fotoPath) {
    final idx = _pengajuan.indexWhere((p) => p.id == pengajuanId);
    if (idx >= 0) {
      _pengajuan[idx].buktiFotoPath = fotoPath;
      _pengajuan[idx].status = KompenStatus.proses;
      notifyListeners();
    }
  }

  void cancelPengajuan(String pengajuanId) {
    _pengajuan.removeWhere((p) => p.id == pengajuanId);
    notifyListeners();
  }

  void verifikasiDosen(String pengajuanId, bool disetujui, {String? catatan}) {
    final idx = _pengajuan.indexWhere((p) => p.id == pengajuanId);
    if (idx < 0) return;
    final p = _pengajuan[idx];
    if (disetujui) {
      p.status = KompenStatus.disetujuiDosen;
      p.tanggalTtdDosen = DateTime.now();
      p.ttdDosenBase64 = 'mock_ttd_dosen';
      // Notify kaprodi
      for (var u in _users.where((u) => u.role == UserRole.kaprodi)) {
        _notifikasi.add(Notifikasi(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          userId: u.id,
          judul: 'Kompen Menunggu Persetujuan Anda',
          pesan: '${p.mahasiswaNama} - "${p.assignmentJudul}" sudah disetujui dosen. Silakan review.',
          waktu: DateTime.now(),
          tipe: 'approval',
          referensiId: pengajuanId,
        ));
      }
      // Notify mahasiswa
      _notifikasi.add(Notifikasi(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}_m',
        userId: p.mahasiswaId,
        judul: 'TTD Dosen Diterima! 🎉',
        pesan: 'Kompen "${p.assignmentJudul}" telah ditandatangani dosen. Menunggu persetujuan Kaprodi.',
        waktu: DateTime.now(),
        tipe: 'ttd',
        referensiId: pengajuanId,
      ));
    } else {
      p.status = KompenStatus.revisi;
      p.catatanDosen = catatan;
      _notifikasi.add(Notifikasi(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        userId: p.mahasiswaId,
        judul: 'Kompen Perlu Revisi',
        pesan: 'Dosen meminta revisi pada kompen "${p.assignmentJudul}". ${catatan ?? ""}',
        waktu: DateTime.now(),
        tipe: 'kompen',
        referensiId: pengajuanId,
      ));
    }
    notifyListeners();
  }

  void approvalKaprodi(String pengajuanId, bool disetujui, {String? catatan}) {
    final idx = _pengajuan.indexWhere((p) => p.id == pengajuanId);
    if (idx < 0) return;
    final p = _pengajuan[idx];
    if (disetujui) {
      p.status = KompenStatus.lunas;
      p.tanggalTtdKaprodi = DateTime.now();
      p.ttdKaprodiBase64 = 'mock_ttd_kaprodi';
      _notifikasi.add(Notifikasi(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        userId: p.mahasiswaId,
        judul: 'Kompen LUNAS! 🎊',
        pesan: 'Selamat! Kompen "${p.assignmentJudul}" telah disetujui Kaprodi. Surat kompen siap dicetak.',
        waktu: DateTime.now(),
        tipe: 'ttd',
        referensiId: pengajuanId,
      ));
    } else {
      p.status = KompenStatus.ditolak;
      p.catatanKaprodi = catatan;
      _notifikasi.add(Notifikasi(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        userId: p.mahasiswaId,
        judul: 'Kompen Ditolak Kaprodi',
        pesan: 'Kompen "${p.assignmentJudul}" tidak disetujui Kaprodi. ${catatan ?? ""}',
        waktu: DateTime.now(),
        tipe: 'kompen',
        referensiId: pengajuanId,
      ));
    }
    notifyListeners();
  }

  // Notifications
  List<Notifikasi> getNotifikasi(String userId) {
    return _notifikasi.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.waktu.compareTo(a.waktu));
  }

  int getUnreadCount(String userId) {
    return _notifikasi.where((n) => n.userId == userId && !n.sudahDibaca).length;
  }

  void markAsRead(String notifId) {
    final idx = _notifikasi.indexWhere((n) => n.id == notifId);
    if (idx >= 0) { _notifikasi[idx].sudahDibaca = true; notifyListeners(); }
  }

  void markAllAsRead(String userId) {
    for (var n in _notifikasi.where((n) => n.userId == userId)) {
      n.sudahDibaca = true;
    }
    notifyListeners();
  }

  // Rekap
  RekapKompen getRekap(String mahasiswaId) {
    final user = _users.firstWhere((u) => u.id == mahasiswaId, orElse: () => _users.first);
    final selesai = _pengajuan
        .where((p) => p.mahasiswaId == mahasiswaId && p.status == KompenStatus.lunas)
        .fold(0, (sum, p) => sum + p.jamKompen);
    return RekapKompen(
      mahasiswaId: mahasiswaId,
      mahasiswaNama: user.nama,
      totalJamWajib: 8, // mock wajib 8 jam
      totalJamSelesai: selesai,
    );
  }
}