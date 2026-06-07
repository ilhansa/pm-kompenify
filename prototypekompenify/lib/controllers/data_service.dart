import 'package:flutter/material.dart';
import '../models/user_model.dart' as api;
import '../models/models.dart';
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';
import '../models/notifikasi_model.dart';
import '../services/auth_service.dart';
import '../services/dosen_service.dart';
import '../services/kaprodi_service.dart';
import '../services/pengajuan_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data_service1.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DosenService _dosenService = DosenService();
  final KaprodiService _kaprodiService = KaprodiService();
  final PengajuanService _pengajuanService = PengajuanService();
  final NotifikasiService _notifikasiService = NotifikasiService();
  final DataService1 _staticService = DataService1();
  final MahasiswaKompenService _mhsService = MahasiswaKompenService();

  List<AssignmentModel> _assignmentsMahasiswa = [];
  List<PengajuanModel> _pengajuanSaya = [];
  List<AssignmentModel> get assignmentsMahasiswa => _assignmentsMahasiswa;
  List<PengajuanModel> get pengajuanSaya => _pengajuanSaya;

  // ─── STATE ─────────────────────────────────────────────────────────────────
  String? _token;
  api.UserModel? _currentUser;
  bool _isLoading = false;

  List<AssignmentModel> _assignmentsApi = [];
  List<AssignmentModel> _assignmentsKaprodi = [];
  List<PengajuanModel> _pengajuanMasuk = [];
  List<NotifikasiModel> _notifikasiList = [];
  List<PengajuanModel> _pengajuanMenungguVerifikasi = [];
  List<PengajuanModel> _pengajuanMenungguVerifikasiKaprodi = [];
  int _unreadCount = 0;

  String? get token => _token;
  api.UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  List<AssignmentModel> get assignmentsApi => _assignmentsApi;
  List<AssignmentModel> get assignmentsKaprodi => _assignmentsKaprodi;
  List<PengajuanModel> get pengajuanMasuk => _pengajuanMasuk;
  List<NotifikasiModel> get notifikasiList => _notifikasiList;
  List<PengajuanModel> get pengajuanMenungguVerifikasi =>
      _pengajuanMenungguVerifikasi;
  List<PengajuanModel> get pengajuanMenungguVerifikasiKaprodi =>
      _pengajuanMenungguVerifikasiKaprodi;
  int get unreadCount => _unreadCount;

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
        await _loadInitialData();
        return null;
      } else {
        notifyListeners();
        return responseData['message'] ?? 'NIM/NIP atau password salah.';
      }
    } else {
      notifyListeners();
      return 'Gagal terhubung ke server. Pastikan server Laravel aktif!';
    }
  }

  Future<void> _loadInitialData() async {
    if (_currentUser == null || _token == null) return;
    final role = _currentUser!.role;
    await fetchNotifikasi();
    if (role == api.UserRole.dosen) {
      await fetchAssignments();
      await fetchPengajuanMasuk();
    }
    if (role == api.UserRole.kaprodi) {
      await fetchAssignments();
      await fetchAssignmentsKaprodi();
      await fetchPengajuanMasuk();
      await fetchPengajuanMenungguVerifikasiKaprodi();
    }
    if (role == api.UserRole.mahasiswa) {
      await fetchAssignmentMahasiswa();
      await fetchPengajuanSaya();
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _assignmentsApi = [];
    _assignmentsKaprodi = [];
    _assignmentsMahasiswa = [];
    _pengajuanMasuk = [];
    _pengajuanSaya = [];
    _notifikasiList = [];
    _pengajuanMenungguVerifikasi = [];
    _pengajuanMenungguVerifikasiKaprodi = [];
    _unreadCount = 0;
    _staticService.logout();
    notifyListeners();
  }

  // ─── ASSIGNMENTS (DOSEN) ────────────────────────────────────────────────────

  Future<void> fetchAssignments() async {
    if (_token == null) return;
    try {
      _assignmentsApi = await _dosenService.getAssignments(_token!);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch assignments: $e');
    }
  }

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
    if (result['success'] == true) await fetchAssignments();
    return result;
  }

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
    if (result['success'] == true) await fetchAssignments();
    return result;
  }

  Future<Map<String, dynamic>> deleteAssignmentApi(String id) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _dosenService.hapusAssignment(_token!, id);
    if (result['success'] == true) {
      _assignmentsApi.removeWhere((a) => a.id == id);
      notifyListeners();
    }
    return result;
  }

  // ─── ASSIGNMENTS KAPRODI ────────────────────────────────────────────────────

  Future<void> fetchAssignmentsKaprodi() async {
    if (_token == null) return;
    try {
      _assignmentsKaprodi = await _kaprodiService.getAssignments(_token!);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch assignments kaprodi: $e');
    }
  }

  Future<Map<String, dynamic>> addAssignmentKaprodiApi({
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _kaprodiService.buatAssignment(
      _token!,
      judul: judul,
      deskripsi: deskripsi,
      jamKompen: jamKompen,
      tanggalMulai: _formatDate(tanggalMulai),
      tanggalSelesai: _formatDate(tanggalSelesai),
    );
    if (result['success'] == true) await fetchAssignmentsKaprodi();
    return result;
  }

  Future<Map<String, dynamic>> editAssignmentKaprodiApi(
    String id, {
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _kaprodiService.editAssignment(
      _token!,
      id,
      judul: judul,
      deskripsi: deskripsi,
      jamKompen: jamKompen,
      tanggalMulai: _formatDate(tanggalMulai),
      tanggalSelesai: _formatDate(tanggalSelesai),
    );
    if (result['success'] == true) await fetchAssignmentsKaprodi();
    return result;
  }

  Future<Map<String, dynamic>> deleteAssignmentKaprodiApi(String id) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _kaprodiService.hapusAssignment(_token!, id);
    if (result['success'] == true) {
      _assignmentsKaprodi.removeWhere((a) => a.id == id);
      notifyListeners();
    }
    return result;
  }

  // ─── PENGAJUAN MASUK (DOSEN/KAPRODI) ───────────────────────────────────────

  Future<void> fetchPengajuanMasuk() async {
    if (_token == null || _currentUser == null) return;
    final role = _currentUser!.role == api.UserRole.dosen ? 'dosen' : 'kaprodi';
    try {
      _pengajuanMasuk = await _pengajuanService.getPengajuanMasuk(
        _token!,
        role,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch pengajuan masuk: $e');
    }
  }

  Future<Map<String, dynamic>> updateStatusPengajuan(
    dynamic id,
    dynamic status,
  ) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

      // Konversi aman untuk ID dan Status agar masuk ke Laravel dalam format string/int yang valid
      final targetId = id.toString();
      final String statusString = status.toString();

      final url = Uri.parse("$baseUrl/dosen/pengajuan-kompen/$targetId/status");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': statusString}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Sukses'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Eror koneksi: $e'};
    }
  }

  // ─── MAHASISWA ──────────────────────────────────────────────────────────────

  Future<void> fetchAssignmentMahasiswa() async {
    if (_token == null) return;
    try {
      _assignmentsMahasiswa = await _mhsService.getAssignmentAktif(_token!);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch assignment mahasiswa: $e');
    }
  }

  Future<void> fetchPengajuanSaya() async {
    if (_token == null) return;
    try {
      _pengajuanSaya = await _mhsService.getPengajuanSaya(_token!);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch pengajuan saya: $e');
    }
  }

  Future<Map<String, dynamic>> ajukanKompen(String assignmentId) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _mhsService.ajukanKompen(_token!, assignmentId);
    if (result['success'] == true) await fetchPengajuanSaya();
    return result;
  }

  Future<Map<String, dynamic>> batalkanPengajuan(String id) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _mhsService.batalkanPengajuan(_token!, id);
    if (result['success'] == true) await fetchPengajuanSaya();
    return result;
  }

  Future<Map<String, dynamic>> uploadBuktiFoto(
    String pengajuanId,
    List<File> files,
  ) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _mhsService.uploadBuktiFoto(
      _token!,
      pengajuanId,
      files,
    );
    if (result['success'] == true) await fetchPengajuanSaya();
    return result;
  }

  Future<Map<String, dynamic>> tandaiSelesai(String pengajuanId) async {
    if (_token == null) return {'success': false, 'message': 'Belum login'};
    final result = await _mhsService.tandaiSelesai(_token!, pengajuanId);
    if (result['success'] == true) await fetchPengajuanSaya();
    return result;
  }

  // ─── NOTIFIKASI ─────────────────────────────────────────────────────────────

  Future<void> fetchNotifikasi() async {
    if (_token == null) return;
    try {
      final result = await _notifikasiService.getNotifikasi(_token!);
      _notifikasiList = result['data'] as List<NotifikasiModel>;
      _unreadCount = result['unread_count'] as int;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch notifikasi: $e');
    }
  }

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
      debugPrint('Gagal mark as read: $e');
    }
  }

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
      debugPrint('Gagal mark all as read: $e');
    }
  }

  // ─── REFRESH ────────────────────────────────────────────────────────────────

  Future<void> refreshDataMahasiswa() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final res = await _authService.getLatestProfile(_token!, baseUrl);
      if (res != null && res['success'] == true)
        _currentUser = api.UserModel.fromJson(res['user']);
      await fetchAssignmentMahasiswa();
      await fetchPengajuanSaya();
      await fetchNotifikasi();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal refresh mahasiswa: $e');
    }
  }

  // GET | Mengambil daftar pengajuan yang menunggu verifikasi (dosen)
  Future<void> fetchPengajuanMenungguVerifikasi() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/pengajuan-kompen/menunggu-verifikasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List data = responseData['data'] ?? [];
        _pengajuanMenungguVerifikasi = data
            .map((json) => PengajuanModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetch pengajuan menunggu verifikasi: $e');
    }
  }

  // GET | Mengambil daftar pengajuan yang menunggu verifikasi (kaprodi)
  Future<void> fetchPengajuanMenungguVerifikasiKaprodi() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.get(
        Uri.parse('$baseUrl/kaprodi/pengajuan-kompen/menunggu-verifikasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List data = responseData['data'] ?? [];
        _pengajuanMenungguVerifikasiKaprodi = data
            .map((json) => PengajuanModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetch pengajuan menunggu verifikasi kaprodi: $e');
    }
  }

  Future<void> refreshDataDosen() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final res = await _authService.getLatestProfile(_token!, baseUrl);
      if (res != null && res['success'] == true)
        _currentUser = api.UserModel.fromJson(res['user']);
      await fetchAssignments();
      await fetchPengajuanMasuk();
      await fetchNotifikasi();
    } catch (e) {
      debugPrint('Gagal refresh dosen: $e');
    }
  }

  Future<void> refreshDataKaprodi() async {
    if (_token == null) return;
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
      final res = await _authService.getLatestProfile(_token!, baseUrl);
      if (res != null && res['success'] == true)
        _currentUser = api.UserModel.fromJson(res['user']);
      await fetchAssignments();
      await fetchAssignmentsKaprodi();
      await fetchPengajuanMasuk();
      await fetchPengajuanMenungguVerifikasiKaprodi();
      await fetchNotifikasi();
    } catch (e) {
      debugPrint('Gagal refresh kaprodi: $e');
    }
  }

  // ─── HELPER ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── STATIS (backward compat) ────────────────────────────────────────────────

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
