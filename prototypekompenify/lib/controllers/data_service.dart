// lib/controllers/data_service.dart
// ✅ Versi API Real - Dosen & Kaprodi sudah tersambung ke Laravel
// Mahasiswa tetap pakai API real (tidak berubah dari sebelumnya)
// Admin tetap statis (belum ada endpoint)

import 'package:flutter/material.dart';
import '../models/user_model.dart' as api;
import '../models/models.dart';
import '../models/assignment_model.dart';
import '../services/auth_service.dart';
import '../services/dosen_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data_service1.dart';

class DataService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DosenService _dosenService = DosenService();
  final DataService1 _staticService = DataService1();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  String? _token;
  api.UserModel? _currentUser;
  bool _isLoading = false;

  // State untuk dosen (API real)
  List<AssignmentModel> _assignmentsApi = [];
  bool _assignmentsLoaded = false;

  String? get token => _token;
  api.UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  List<AssignmentModel> get assignmentsApi => _assignmentsApi;

  // ─── AUTH ───────────────────────────────────────────────────────────────────

  Future<String?> loginRestApi(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final responseData = await _authService.attemptLogin(username, password);

    _isLoading = false;

    if (responseData != null) {
      if (responseData.containsKey('access_token')) {
        _token = responseData['access_token'];
        _currentUser = api.UserModel.fromJson(responseData['user']);
        notifyListeners();

        // Auto-load data sesuai role setelah login
        if (_currentUser!.role == api.UserRole.dosen ||
            _currentUser!.role == api.UserRole.kaprodi) {
          await fetchAssignments();
        }

        return null; // Login sukses
      } else {
        notifyListeners();
        return responseData['message'] ?? 'NIM/NIP atau password salah.';
      }
    } else {
      notifyListeners();
      return 'Gagal terhubung ke server. Pastikan server Laravel aktif!';
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _assignmentsApi = [];
    _assignmentsLoaded = false;
    _staticService.logout();
    notifyListeners();
  }

  // ─── ASSIGNMENTS (API REAL) ─────────────────────────────────────────────────

  /// Ambil semua assignment dari API Laravel
  /// Dipanggil otomatis setelah login, atau saat pull-to-refresh
  Future<void> fetchAssignments() async {
    if (_token == null) return;
    try {
      _assignmentsApi = await _dosenService.getAssignments(_token!);
      _assignmentsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch assignments: $e');
    }
  }

  /// Buat assignment baru ke API Laravel
  /// Dipanggil dari dosen_assignment.dart saat tombol "Buat Assignment" ditekan
  Future<Map<String, dynamic>> addAssignmentApi({
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};

    final result = await _dosenService.buatAssignment(
      _token!,
      judul: judul,
      deskripsi: deskripsi,
      jamKompen: jamKompen,
      tanggalMulai: _formatDate(tanggalMulai),
      tanggalSelesai: _formatDate(tanggalSelesai),
    );

    if (result['success'] == true) {
      await fetchAssignments(); // Refresh list setelah berhasil
    }
    return result;
  }

  /// Edit assignment yang sudah ada
  /// Dipanggil dari dosen_assignment.dart saat tombol "Simpan Perubahan" ditekan
  Future<Map<String, dynamic>> editAssignmentApi(
    String id, {
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};

    final result = await _dosenService.editAssignment(
      _token!,
      id,
      judul: judul,
      deskripsi: deskripsi,
      jamKompen: jamKompen,
      tanggalMulai: _formatDate(tanggalMulai),
      tanggalSelesai: _formatDate(tanggalSelesai),
    );

    if (result['success'] == true) {
      await fetchAssignments(); // Refresh list setelah berhasil
    }
    return result;
  }

  /// Hapus assignment
  /// Dipanggil dari dosen_assignment.dart saat tombol "Hapus" ditekan
  Future<Map<String, dynamic>> deleteAssignmentApi(String id) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};

    final result = await _dosenService.hapusAssignment(_token!, id);

    if (result['success'] == true) {
      _assignmentsApi.removeWhere((a) => a.id == id);
      notifyListeners();
    }
    return result;
  }

  // ─── REFRESH ────────────────────────────────────────────────────────────────

  Future<void> refreshDataMahasiswa() async {
    if (_token == null) return;
    try {
      final String baseUrl =
          dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final responseData =
          await _authService.getLatestProfile(_token!, baseUrl);
      if (responseData != null && responseData['success'] == true) {
        _currentUser = api.UserModel.fromJson(responseData['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal refresh mahasiswa: $e');
    }
  }

  Future<void> refreshDataDosen() async {
    if (_token == null) return;
    try {
      // Refresh profil user (sisa jam, dll)
      final String baseUrl =
          dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final responseData =
          await _authService.getLatestProfile(_token!, baseUrl);
      if (responseData != null && responseData['success'] == true) {
        _currentUser = api.UserModel.fromJson(responseData['user']);
      }
      // Refresh list assignment dari API
      await fetchAssignments();
    } catch (e) {
      debugPrint('Gagal refresh dosen: $e');
    }
  }

  Future<void> refreshDataKaprodi() async {
    if (_token == null) return;
    try {
      final String baseUrl =
          dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final responseData =
          await _authService.getLatestProfile(_token!, baseUrl);
      if (responseData != null && responseData['success'] == true) {
        _currentUser = api.UserModel.fromJson(responseData['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal refresh kaprodi: $e');
    }
  }

  // ─── HELPER ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    // Format: "2025-01-15" sesuai yang diminta Laravel
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ─── JALUR STATIS (tidak berubah) ───────────────────────────────────────────

  User? get staticCurrentUser => _staticService.currentUser;

  List<User> getUsers({UserRole? role}) => _staticService.getUsers(role: role);
  void addUser(User user) { _staticService.addUser(user); notifyListeners(); }
  void updateUser(User user) { _staticService.updateUser(user); notifyListeners(); }
  void deleteUser(String id) { _staticService.deleteUser(id); notifyListeners(); }

  // Assignments statis (masih dipakai komponen lama / mahasiswa)
  List<Assignment> getAssignments({String? dosenId, bool availableOnly = false}) =>
      _staticService.getAssignments(dosenId: dosenId, availableOnly: availableOnly);
  void addAssignment(Assignment assignment) { _staticService.addAssignment(assignment); notifyListeners(); }
  void updateAssignment(Assignment assignment) { _staticService.updateAssignment(assignment); notifyListeners(); }
  void deleteAssignment(String id) { _staticService.deleteAssignment(id); notifyListeners(); }
  bool pilihAssignment(String assignmentId, String mahasiswaId) {
    final result = _staticService.pilihAssignment(assignmentId, mahasiswaId);
    notifyListeners();
    return result;
  }

  List<PengajuanKompen> getPengajuan({String? mahasiswaId, String? dosenId, KompenStatus? status}) =>
      _staticService.getPengajuan(mahasiswaId: mahasiswaId, dosenId: dosenId, status: status);
  void addPengajuan(PengajuanKompen pengajuan) { _staticService.addPengajuan(pengajuan); notifyListeners(); }
  void uploadBukti(String pengajuanId, String fotoPath) { _staticService.uploadBukti(pengajuanId, fotoPath); notifyListeners(); }
  void cancelPengajuan(String pengajuanId) { _staticService.cancelPengajuan(pengajuanId); notifyListeners(); }
  void verifikasiDosen(String pengajuanId, bool disetujui, {String? catatan}) {
    _staticService.verifikasiDosen(pengajuanId, disetujui, catatan: catatan);
    notifyListeners();
  }
  void approvalKaprodi(String pengajuanId, bool disetujui, {String? catatan}) {
    _staticService.approvalKaprodi(pengajuanId, disetujui, catatan: catatan);
    notifyListeners();
  }

  List<Notifikasi> getNotifikasi(String userId) => _staticService.getNotifikasi(userId);
  int getUnreadCount(String userId) => _staticService.getUnreadCount(userId);
  void markAsRead(String notifId) { _staticService.markAsRead(notifId); notifyListeners(); }
  void markAllAsRead(String userId) { _staticService.markAllAsRead(userId); notifyListeners(); }
  RekapKompen getRekap(String mahasiswaId) => _staticService.getRekap(mahasiswaId);
}