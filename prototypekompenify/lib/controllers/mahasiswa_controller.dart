import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';
import '../services/pengajuan_service.dart'; // Memanggil class MahasiswaKompenService mentah Anda

class MahasiswaController extends ChangeNotifier {
  // Instance untuk memanggil HTTP Request ke REST API Laravel
  final MahasiswaKompenService _mhsService = MahasiswaKompenService();

  // ─── STATE UTAMA MAHASISWA ───
  List<AssignmentModel> _assignmentsMahasiswa = [];
  List<PengajuanModel> _pengajuanSaya = [];
  bool _isLoading = false;

  // ─── GETTER DATA ───
  List<AssignmentModel> get assignmentsMahasiswa => _assignmentsMahasiswa;
  List<PengajuanModel> get pengajuanSaya => _pengajuanSaya;
  bool get isLoading => _isLoading;

  // 1. Mengambil Daftar Tugas Kompen Aktif di Aplikasi Mobile
  Future<void> fetchAssignmentMahasiswa(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _assignmentsMahasiswa = await _mhsService.getAssignmentAktif(token);
    } catch (e) {
      debugPrint('Gagal mengambil data tugas mahasiswa: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Mengambil Riwayat Pengajuan Kompen Milik Mahasiswa yang Login
  Future<void> fetchPengajuanSaya(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _pengajuanSaya = await _mhsService.getPengajuanSaya(token);
    } catch (e) {
      debugPrint('Gagal mengambil data pengajuan saya: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Melakukan Pengajuan Tugas Kompen Baru
  Future<Map<String, dynamic>> ajukanKompen(
    String token,
    String assignmentId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.ajukanKompen(token, assignmentId);
      if (result['success'] == true) {
        await fetchPengajuanSaya(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Membatalkan Pengajuan Tugas Kompen
  Future<Map<String, dynamic>> batalkanPengajuan(
    String token,
    String id,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.batalkanPengajuan(token, id);
      if (result['success'] == true) {
        await fetchPengajuanSaya(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Mengunggah Foto Bukti Selesai Mengerjakan Kompen
  Future<Map<String, dynamic>> uploadBuktiFoto(
    String token,
    String pengajuanId,
    List<File> files,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.uploadBuktiFoto(
        token,
        pengajuanId,
        files,
      );
      if (result['success'] == true) {
        await fetchPengajuanSaya(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. Menghapus Bukti Foto Terpilih yang Sudah Diunggah
  Future<Map<String, dynamic>> hapusBuktiFoto(
    String token,
    String pengajuanId,
    String fotoUrl,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.delete(
        Uri.parse('$baseUrl/mahasiswa/pengajuan/$pengajuanId/bukti-foto'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'foto_url': fotoUrl}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await fetchPengajuanSaya(token);
        return {
          'success': true,
          'message': data['message'] ?? 'Foto berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus foto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 7. Menandai Tugas Kompen Telah Selesai Dikirim
  Future<Map<String, dynamic>> tandaiSelesai(
    String token,
    String pengajuanId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.tandaiSelesai(token, pengajuanId);
      if (result['success'] == true) {
        await fetchPengajuanSaya(token);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
