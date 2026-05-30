import 'package:flutter/material.dart';
import '../models/user_model.dart' as api;
import '../models/models.dart'; // Tetap import model statis lama untuk operan data
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data_service1.dart'; // Import data_service1 yang sudah kamu ganti nama kelasnya

class DataService extends ChangeNotifier {
  // Instansiasi layer Service untuk REST API Laravel
  final AuthService _authService = AuthService();

  // Instansiasi DataService1 statis sebagai back-up data lokal
  final DataService1 _staticService = DataService1();

  // ===========================================================================
  // STATE & DATA UTAMA (REST API & AUTH)
  // ===========================================================================
  String? _token;
  api.UserModel? _currentUser; // Menggunakan UserModel REST API baru
  bool _isLoading = false;

  String? get token => _token;
  api.UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  /// Fungsi logika login REST API Laravel
  Future<String?> loginRestApi(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final responseData = await _authService.attemptLogin(username, password);

    print("=== DEBUG RESPON NGROK ===");
    print(responseData);
    print("==========================");

    _isLoading = false;

    if (responseData != null) {
      if (responseData.containsKey('access_token')) {
        _token = responseData['access_token'];
        _currentUser = api.UserModel.fromJson(responseData['user']);

        notifyListeners();
        return null; // Login Sukses
      } else {
        notifyListeners();
        return responseData['message'] ?? 'NIM/NIP atau password salah.';
      }
    } else {
      notifyListeners();
      return 'Gagal terhubung ke server. Pastikan Ngrok atau server Laravel aktif!';
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _staticService.logout(); // Sekalian bersihkan sesi statis jika ada
    notifyListeners();
  }

  // ===========================================================================
  // JALUR OPERAN KE DATA_SERVICE1 (STATIS)
  // Disesuaikan 100% dengan fungsi asli yang ada di data_service1.dart kamu
  // ===========================================================================

  // Getter User bawaan statis (jika View lamamu masih mencari get currentUser lama)
  User? get staticCurrentUser => _staticService.currentUser;

  // --- LOGIKA USERS (STATIS) ---
  List<User> getUsers({UserRole? role}) => _staticService.getUsers(role: role);
  void addUser(User user) {
    _staticService.addUser(user);
    notifyListeners();
  }

  void updateUser(User user) {
    _staticService.updateUser(user);
    notifyListeners();
  }

  void deleteUser(String id) {
    _staticService.deleteUser(id);
    notifyListeners();
  }

  // --- LOGIKA ASSIGNMENTS / TUGAS (STATIS) ---
  List<Assignment> getAssignments({
    String? dosenId,
    bool availableOnly = false,
  }) {
    return _staticService.getAssignments(
      dosenId: dosenId,
      availableOnly: availableOnly,
    );
  }

  void addAssignment(Assignment assignment) {
    _staticService.addAssignment(assignment);
    notifyListeners();
  }

  void updateAssignment(Assignment assignment) {
    _staticService.updateAssignment(assignment);
    notifyListeners();
  }

  void deleteAssignment(String id) {
    _staticService.deleteAssignment(id);
    notifyListeners();
  }

  bool pilihAssignment(String assignmentId, String mahasiswaId) {
    final result = _staticService.pilihAssignment(assignmentId, mahasiswaId);
    notifyListeners();
    return result;
  }

  // --- LOGIKA PENGAJUAN KOMPEN (STATIS) ---
  List<PengajuanKompen> getPengajuan({
    String? mahasiswaId,
    String? dosenId,
    KompenStatus? status,
  }) {
    return _staticService.getPengajuan(
      mahasiswaId: mahasiswaId,
      dosenId: dosenId,
      status: status,
    );
  }

  void addPengajuan(PengajuanKompen pengajuan) {
    _staticService.addPengajuan(pengajuan);
    notifyListeners();
  }

  void uploadBukti(String pengajuanId, String fotoPath) {
    _staticService.uploadBukti(pengajuanId, fotoPath);
    notifyListeners();
  }

  void cancelPengajuan(String pengajuanId) {
    _staticService.cancelPengajuan(pengajuanId);
    notifyListeners();
  }

  void verifikasiDosen(String pengajuanId, bool disetujui, {String? catatan}) {
    _staticService.verifikasiDosen(pengajuanId, disetujui, catatan: catatan);
    notifyListeners();
  }

  void approvalKaprodi(String pengajuanId, bool disetujui, {String? catatan}) {
    _staticService.approvalKaprodi(pengajuanId, disetujui, catatan: catatan);
    notifyListeners();
  }

  // --- LOGIKA NOTIFIKASI (STATIS) ---
  List<Notifikasi> getNotifikasi(String userId) =>
      _staticService.getNotifikasi(userId);
  int getUnreadCount(String userId) => _staticService.getUnreadCount(userId);
  void markAsRead(String notifId) {
    _staticService.markAsRead(notifId);
    notifyListeners();
  }

  void markAllAsRead(String userId) {
    _staticService.markAllAsRead(userId);
    notifyListeners();
  }

  // --- LOGIKA REKAP KOMPEN (STATIS) ---
  RekapKompen getRekap(String mahasiswaId) =>
      _staticService.getRekap(mahasiswaId);

  // ===========================================================================
  // FUNGSI REFRESH ASLI (MENGKONEKSIKAN VIEW DAN LARAVEL BACKEND)
  // ===========================================================================
  Future<void> refreshDataMahasiswa() async {
    // Jika token kosong atau user belum login, batalkan otomatis
    if (_token == null) return;

    try {
      // 1. Definisikan BASE_URL Ngrok kamu (bisa hardcode atau ambil dari .env)
        final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
 // <-- Ganti pakai URL Ngrok aktifmu, Bos!

      // 2. Suruh _authService mengambil data JSON profil terbaru dari Laravel
      final responseData = await _authService.getLatestProfile(
        _token!,
        _baseUrl,
      );

      if (responseData != null && responseData['success'] == true) {
        debugPrint("=== PULL TO REFRESH BERHASIL ===");
        debugPrint("Data Terbaru: ${responseData['user']}");

        // 3. Timpa data user lama dengan data fresh hasil query MySQL Laravel terbaru
        _currentUser = api.UserModel.fromJson(responseData['user']);

        // 4. TERIAK! Beritahu semua halaman (View) agar langsung menggambar ulang angkanya
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi otomatis via Pull-to-Refresh: $e");
    }
  }

  // ===========================================================================
  // FUNGSI REFRESH UNTUK DOSEN
  // ===========================================================================
  Future<void> refreshDataDosen() async {
    if (_token == null) return;
    try {
        final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';// Sesuaikan URL Ngrok kamu
      final responseData = await _authService.getLatestProfile(_token!, _baseUrl);

      if (responseData != null && responseData['success'] == true) {
        _currentUser = api.UserModel.fromJson(responseData['user']);
        notifyListeners(); 
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi dosen: $e");
    }
  }
}
