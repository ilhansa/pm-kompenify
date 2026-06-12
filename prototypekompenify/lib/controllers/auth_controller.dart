import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart' as api;
import '../models/models.dart'; // Untuk data statis lama jika dibutuhkan
import '../models/notifikasi_model.dart';
import '../services/auth_service.dart';
import '../services/pengajuan_service.dart';
import 'data_service1.dart'; // Menjaga kompatibilitas data statis Anda

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotifikasiService _notifikasiService = NotifikasiService();
  final DataService1 _staticService = DataService1();

  // ─── STATE UTAMA AUTH & NOTIFIKASI ───
  String? _token;
  api.UserModel? _currentUser;
  bool _isLoading = false;
  List<NotifikasiModel> _notifikasiList = [];
  int _unreadCount = 0;

  // ─── GETTER GLOBAL ───
  String? get token => _token;
  api.UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  List<NotifikasiModel> get notifikasiList => _notifikasiList;
  int get unreadCount => _unreadCount;

  // 1. Proses Login REST API Laravel
  Future<String?> loginRestApi(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _authService.attemptLogin(username, password);
      _isLoading = false;

      if (responseData != null) {
        if (responseData.containsKey('access_token')) {
          _token = responseData['access_token'];
          _currentUser = api.UserModel.fromJson(responseData['user']);
          notifyListeners();

          // Load data notifikasi awal secara otomatis setelah login berhasil
          await fetchNotifikasi();
          return null; // Return null menandakan login sukses tanpa error
        } else {
          notifyListeners();
          return responseData['message'] ?? 'NIM/NIP atau password salah.';
        }
      } else {
        notifyListeners();
        return 'Gagal terhubung ke server. Pastikan server Laravel aktif!';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan koneksi: $e';
    }
  }

  // 2. Proses Logout & Pembersihan State Sesi
  void logout() {
    _token = null;
    _currentUser = null;
    _notifikasiList = [];
    _unreadCount = 0;
    _staticService.logout();
    notifyListeners();
  }

  // 3. Mengambil Data Notifikasi Pengguna dari API
  Future<void> fetchNotifikasi() async {
    if (_token == null) return;
    try {
      final result = await _notifikasiService.getNotifikasi(_token!);
      _notifikasiList = result['data'] as List<NotifikasiModel>;
      _unreadCount = result['unread_count'] as int;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal mengambil data notifikasi: $e');
    }
  }

  // 4. Menandai Satu Notifikasi Telah Dibaca
  Future<void> markNotifikasiAsRead(String id) async {
    if (_token == null) return;
    try {
      await _notifikasiService.markAsRead(_token!, id);
      final idx = _notifikasiList.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final n = _notifikasiList[idx];
        _notifikasiList[idx] = NotifikasiModel(
          id: n.id,
          userId: n.userId,
          judul: n.judul,
          pesan: n.pesan,
          isRead: true,
          createdAt: n.createdAt,
        );
        _unreadCount = _notifikasiList.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal menandai baca notifikasi: $e');
    }
  }

  // 5. Menandai Semua Notifikasi Telah Dibaca
  Future<void> markAllNotifikasiAsRead() async {
    if (_token == null) return;
    try {
      await _notifikasiService.markAllAsRead(_token!);
      _notifikasiList = _notifikasiList
          .map(
            (n) => NotifikasiModel(
              id: n.id,
              userId: n.userId,
              judul: n.judul,
              pesan: n.pesan,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menandai semua notifikasi: $e');
    }
  }

  // 6. Sinkronisasi Ulang Profil Pengguna Terbaru
  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final res = await _authService.getLatestProfile(_token!, baseUrl);
      if (res != null && res['success'] == true) {
        _currentUser = api.UserModel.fromJson(res['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal sinkronisasi profil: $e');
    }
  }

  // 7. 🎯 FUNGSI VERIFIKASI SATU PINTU (PUT) - Diakses Bersama oleh Dosen & Kaprodi
  Future<Map<String, dynamic>> verifikasiPengajuan({
    required dynamic id,
    required String status,
    required String role,
  }) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};

    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.put(
        Uri.parse(
          "$baseUrl/$role/pengajuan-kompen/${id.toString()}/verifikasi",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil diproses!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi ke server: $e'};
    }
  }

  // ─── BACKWARD COMPATIBILITY DATA STATIS LAMA ───
  User? get staticCurrentUser => _staticService.currentUser;
  List<User> getUsers({UserRole? role}) => _staticService.getUsers(role: role);
  void addUser(User u) {
    _staticService.addUser(u);
    notifyListeners();
  }

  void updateUser(User u) {
    _staticService.updateUser(u);
    notifyListeners();
  }

  void deleteUser(String id) {
    _staticService.deleteUser(id);
    notifyListeners();
  }

  List<Assignment> getAssignments({
    String? dosenId,
    bool availableOnly = false,
  }) => _staticService.getAssignments(
    dosenId: dosenId,
    availableOnly: availableOnly,
  );
  void addAssignment(Assignment a) {
    _staticService.addAssignment(a);
    notifyListeners();
  }

  void updateAssignment(Assignment a) {
    _staticService.updateAssignment(a);
    notifyListeners();
  }

  void deleteAssignment(String id) {
    _staticService.deleteAssignment(id);
    notifyListeners();
  }

  bool pilihAssignment(String aId, String mId) {
    final r = _staticService.pilihAssignment(aId, mId);
    notifyListeners();
    return r;
  }

  List<PengajuanKompen> getPengajuan({
    String? mahasiswaId,
    String? dosenId,
    KompenStatus? status,
  }) => _staticService.getPengajuan(
    mahasiswaId: mahasiswaId,
    dosenId: dosenId,
    status: status,
  );
  void addPengajuan(PengajuanKompen p) {
    _staticService.addPengajuan(p);
    notifyListeners();
  }

  void uploadBukti(String id, String path) {
    _staticService.uploadBukti(id, path);
    notifyListeners();
  }

  void cancelPengajuan(String id) {
    _staticService.cancelPengajuan(id);
    notifyListeners();
  }

  void verifikasiDosen(String id, bool ok, {String? catatan}) {
    _staticService.verifikasiDosen(id, ok, catatan: catatan);
    notifyListeners();
  }

  void approvalKaprodi(String id, bool ok, {String? catatan}) {
    _staticService.approvalKaprodi(id, ok, catatan: catatan);
    notifyListeners();
  }

  List<Notifikasi> getNotifikasi(String userId) =>
      _staticService.getNotifikasi(userId);
  int getUnreadCount(String userId) => _staticService.getUnreadCount(userId);
  void markAsRead(String id) {
    _staticService.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead(String userId) {
    _staticService.markAllAsRead(userId);
    notifyListeners();
  }

  RekapKompen getRekap(String mahasiswaId) =>
      _staticService.getRekap(mahasiswaId);
}
