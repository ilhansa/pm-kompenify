import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';
import '../services/dosen_service.dart'; // Pastikan path ke service mentah Anda sudah benar
import '../services/pengajuan_service.dart';

class DosenController extends ChangeNotifier {
  // Instance dari service mentah untuk HTTP Request ke API Laravel
  final DosenService _dosenService = DosenService();
  final PengajuanService _pengajuanService = PengajuanService();

  // ─── STATE UTAMA DOSEN ───
  List<AssignmentModel> _assignmentsApi = [];
  List<PengajuanModel> _pengajuanMasuk = [];
  List<PengajuanModel> _pengajuanMenungguVerifikasi = [];
  bool _isLoading = false;

  // ─── GETTER DATA ───
  List<AssignmentModel> get assignmentsApi => _assignmentsApi;
  List<PengajuanModel> get pengajuanMasuk => _pengajuanMasuk;
  List<PengajuanModel> get pengajuanMenungguVerifikasi =>
      _pengajuanMenungguVerifikasi;
  bool get isLoading => _isLoading;

  // 1. Mengambil Daftar Tugas Kompen yang Pernah Dibuat Oleh Dosen
// Tambahkan parameter forceRefresh dengan nilai default false
  Future<void> fetchAssignments(String token, {bool forceRefresh = false}) async {
    // SATPAM: Jika data sudah ada di memori DAN tidak sedang dipaksa refresh, STOP di sini!
    if (_assignmentsApi.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();
    try {
      _assignmentsApi = await _dosenService.getAssignments(token);
    } catch (e) {
      debugPrint('Gagal fetch assignments dosen: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Mengambil Seluruh Pengajuan yang Masuk ke Area Dosen
  Future<void> fetchPengajuanMasuk(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _pengajuanMasuk = await _pengajuanService.getPengajuanMasuk(
        token,
        'dosen',
      );
    } catch (e) {
      debugPrint('Gagal fetch pengajuan masuk dosen: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Mengambil Antrean Validasi Pengajuan yang Menunggu Verifikasi Dosen
  Future<void> fetchPengajuanMenungguVerifikasi(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/pengajuan-kompen/menunggu-verifikasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List data = responseData['data'] ?? [];
        _pengajuanMenungguVerifikasi = data
            .map((json) => PengajuanModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetch pengajuan menunggu verifikasi dosen: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Membuat Tugas Kompen Baru (Dosen)
  Future<Map<String, dynamic>> addAssignmentApi(
    String token, {
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _dosenService.buatAssignment(
        token,
        judul: judul,
        deskripsi: deskripsi,
        jamKompen: jamKompen,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );
      if (result['success'] == true) {
        await fetchAssignments(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Mengubah Detail Tugas Kompen (Dosen)
  Future<Map<String, dynamic>> editAssignmentApi(
    String token,
    String id, {
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _dosenService.editAssignment(
        token,
        id,
        judul: judul,
        deskripsi: deskripsi,
        jamKompen: jamKompen,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );
      if (result['success'] == true) {
        await fetchAssignments(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. Menghapus Tugas Kompen (Dosen)
  Future<Map<String, dynamic>> deleteAssignmentApi(
    String token,
    String id,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _dosenService.hapusAssignment(token, id);
      if (result['success'] == true) {
        _assignmentsApi.removeWhere((a) => a.id == id);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 7. Membubuhkan Tanda Tangan Digital Dosen (E-TTD) pada Pengajuan Mahasiswa
  Future<Map<String, dynamic>> generateTandaTanganDigitalDosen(
    dynamic id,
    String token,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.post(
        Uri.parse("$baseUrl/dosen/pengajuan-kompen/$id/ttd"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'E-TTD Dosen sukses dibubuhkan!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses tanda tangan',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Eror koneksi ke server TTD: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
