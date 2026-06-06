import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/pengajuan_model.dart';
import '../models/notifikasi_model.dart';
import '../models/assignment_model.dart';

class PengajuanService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<PengajuanModel>> getPengajuanMasuk(String token, String role) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/$role/pengajuan-kompen'),
      headers: _headers(token),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((e) => PengajuanModel.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil data pengajuan');
  }

  Future<Map<String, dynamic>> updateStatus(
    String token, String role, String pengajuanId, String status) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/$role/pengajuan-kompen/$pengajuanId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(res.body);
  }
}

// ─── NOTIFIKASI SERVICE ────────────────────────────────────────────────────────

class NotifikasiService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> getNotifikasi(String token) async {
    final res = await http.get(Uri.parse('$_baseUrl/notifikasi'), headers: _headers(token));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return {
        'data': (body['data'] as List).map((e) => NotifikasiModel.fromJson(e)).toList(),
        'unread_count': body['unread_count'] ?? 0,
      };
    }
    throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
  }

  Future<Map<String, dynamic>> markAsRead(String token, String id) async {
    final res = await http.put(Uri.parse('$_baseUrl/notifikasi/$id/read'), headers: _headers(token));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> markAllAsRead(String token) async {
    final res = await http.put(Uri.parse('$_baseUrl/notifikasi/read-all'), headers: _headers(token));
    return jsonDecode(res.body);
  }
}

// ─── MAHASISWA SERVICE ─────────────────────────────────────────────────────────

class MahasiswaKompenService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<AssignmentModel>> getAssignmentAktif(String token) async {
    final res = await http.get(Uri.parse('$_baseUrl/mahasiswa/assignments'), headers: _headers(token));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((e) => AssignmentModel.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil assignment');
  }

  Future<List<PengajuanModel>> getPengajuanSaya(String token) async {
    final res = await http.get(Uri.parse('$_baseUrl/mahasiswa/pengajuan-kompen'), headers: _headers(token));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((e) => PengajuanModel.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil pengajuan');
  }

  Future<Map<String, dynamic>> ajukanKompen(String token, String assignmentId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/mahasiswa/pengajuan-kompen'),
      headers: _headers(token),
      body: jsonEncode({'assignment_id': assignmentId}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> batalkanPengajuan(String token, String id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/mahasiswa/pengajuan-kompen/$id'),
      headers: _headers(token),
    );
    return jsonDecode(res.body);
  }

  // ✅ BARU: Upload bukti foto (multipart)
  // POST /api/mahasiswa/pengajuan-kompen/{id}/upload-bukti
  Future<Map<String, dynamic>> uploadBuktiFoto(String token, String pengajuanId, List<File> files) async {
    final uri = Uri.parse('$_baseUrl/mahasiswa/pengajuan-kompen/$pengajuanId/upload-bukti');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    for (final file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'png' : 'jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'bukti_foto[]',
        file.path,
        contentType: MediaType('image', mime),
      ));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  // ✅ BARU: Tandai tugas selesai oleh mahasiswa
  // PUT /api/mahasiswa/pengajuan-kompen/{id}/selesai
  Future<Map<String, dynamic>> tandaiSelesai(String token, String pengajuanId) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/mahasiswa/pengajuan-kompen/$pengajuanId/selesai'),
      headers: _headers(token),
    );
    return jsonDecode(res.body);
  }
}