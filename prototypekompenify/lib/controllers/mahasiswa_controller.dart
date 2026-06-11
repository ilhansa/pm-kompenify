import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';
import '../services/pengajuan_service.dart';
import 'package:geolocator/geolocator.dart';

class MahasiswaController extends ChangeNotifier {
  final MahasiswaKompenService _mhsService = MahasiswaKompenService();

  List<AssignmentModel> _assignmentsMahasiswa = [];
  List<PengajuanModel> _pengajuanSaya = [];
  bool _isLoading = false;

  List<AssignmentModel> get assignmentsMahasiswa => _assignmentsMahasiswa;
  List<PengajuanModel> get pengajuanSaya => _pengajuanSaya;
  bool get isLoading => _isLoading;

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

  Future<Map<String, dynamic>> ajukanKompen(
    String token,
    String assignmentId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.ajukanKompen(token, assignmentId);
      if (result['success'] == true) await fetchPengajuanSaya(token);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> batalkanPengajuan(
    String token,
    String id,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.batalkanPengajuan(token, id);
      if (result['success'] == true) await fetchPengajuanSaya(token);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> uploadBuktiFoto(
    String token,
    String pengajuanId,
    List<File> files,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.uploadBuktiFoto(token, pengajuanId, files);
      if (result['success'] == true) await fetchPengajuanSaya(token);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ FIX: Pakai buktiId (UUID foto), bukan pengajuanId
  // Endpoint: DELETE /api/mahasiswa/bukti-kompen/{buktiId}
  Future<Map<String, dynamic>> hapusBuktiFoto(
    String token,
    String buktiId, // ← BUKAN pengajuanId, tapi ID foto spesifik
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final response = await http.delete(
        Uri.parse('$baseUrl/mahasiswa/bukti-kompen/$buktiId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await fetchPengajuanSaya(token);
        return {'success': true, 'message': data['message'] ?? 'Foto berhasil dihapus'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal menghapus foto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> tandaiSelesai(
    String token,
    String pengajuanId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _mhsService.tandaiSelesai(token, pengajuanId);
      if (result['success'] == true) await fetchPengajuanSaya(token);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<Position?> _dapatkanLokasiSaatIni() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Cek apakah GPS HP menyala
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('GPS belum dinyalakan, Bos!');
  }

  // Cek status izin
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Izin akses lokasi ditolak!');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error('Izin lokasi diblokir permanen oleh sistem HP.');
  } 

  // Ambil titik koordinat paling akurat
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}
}