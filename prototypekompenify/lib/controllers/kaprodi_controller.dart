import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';
import '../services/kaprodi_service.dart'; // Menghubungkan ke service mentah Kaprodi Anda
import '../services/pengajuan_service.dart';

class KaprodiController extends ChangeNotifier {
  final KaprodiService _kaprodiService = KaprodiService();
  final PengajuanService _pengajuanService = PengajuanService();

  // ─── STATE UTAMA KAPRODI ───
  List<AssignmentModel> _assignmentsKaprodi = [];
  List<PengajuanModel> _pengajuanMasuk = [];
  List<PengajuanModel> _pengajuanMenungguVerifikasiKaprodi = [];
  bool _isLoading = false;

  // ─── GETTER DATA ───
  List<AssignmentModel> get assignmentsKaprodi => _assignmentsKaprodi;
  List<PengajuanModel> get pengajuanMasuk => _pengajuanMasuk;
  List<PengajuanModel> get pengajuanMenungguVerifikasiKaprodi =>
      _pengajuanMenungguVerifikasiKaprodi;
  bool get isLoading => _isLoading;

  // 1. Mengambil Daftar Tugas Kompen Milik Program Studi (Kaprodi)
  Future<void> fetchAssignmentsKaprodi(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _assignmentsKaprodi = await _kaprodiService.getAssignments(token);
    } catch (e) {
      debugPrint('Gagal fetch assignments kaprodi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Mengambil Seluruh Pengajuan Kompen yang Masuk ke Kaprodi
  Future<void> fetchPengajuanMasukKaprodi(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _pengajuanMasuk = await _pengajuanService.getPengajuanMasuk(
        token,
        'kaprodi',
      );
    } catch (e) {
      debugPrint('Gagal fetch pengajuan masuk kaprodi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Mengambil Antrean Validasi Pengajuan Menunggu Verifikasi Kaprodi
  Future<void> fetchPengajuanMenungguVerifikasiKaprodi(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.get(
        Uri.parse('$baseUrl/kaprodi/pengajuan-kompen/menunggu-verifikasi'),
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
        _pengajuanMenungguVerifikasiKaprodi = data
            .map((json) => PengajuanModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetch pengajuan menunggu verifikasi kaprodi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Membuat Tugas Kompen Baru (Kaprodi)
  Future<Map<String, dynamic>> addAssignmentKaprodiApi(
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
      final result = await _kaprodiService.buatAssignment(
        token,
        judul: judul,
        deskripsi: deskripsi,
        jamKompen: jamKompen,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );
      if (result['success'] == true) {
        await fetchAssignmentsKaprodi(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Mengubah Detail Tugas Kompen (Kaprodi)
  Future<Map<String, dynamic>> editAssignmentKaprodiApi(
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
      final result = await _kaprodiService.editAssignment(
        token,
        id,
        judul: judul,
        deskripsi: deskripsi,
        jamKompen: jamKompen,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );
      if (result['success'] == true) {
        await fetchAssignmentsKaprodi(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. Menghapus Tugas Kompen (Kaprodi)
  Future<Map<String, dynamic>> deleteAssignmentKaprodiApi(
    String token,
    String id,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _kaprodiService.hapusAssignment(token, id);
      if (result['success'] == true) {
        _assignmentsKaprodi.removeWhere((a) => a.id == id);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 7. Membubuhkan Tanda Tangan Digital Kaprodi (E-TTD) via API Laravel
  Future<Map<String, dynamic>> berikanTandaTanganKaprodi(
    dynamic id,
    String token,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.post(
        Uri.parse("$baseUrl/kaprodi/pengajuan-kompen/${id.toString()}/ttd"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'E-TTD Kaprodi sukses dibubuhkan!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses tanda tangan Kaprodi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Eror koneksi ke server Kaprodi: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
