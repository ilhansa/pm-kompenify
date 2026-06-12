// lib/services/kaprodi_service.dart
// Sambungkan ke: /api/kaprodi/assignments (GET, POST, PUT, DELETE)
// Wajib login dulu → token disimpan di DataService._token
//
// API Endpoints yang digunakan:
//   GET    /api/kaprodi/assignments              → index()
//   GET    /api/kaprodi/assignments/{id}         → show()
//   POST   /api/kaprodi/assignments              → store()
//   PUT    /api/kaprodi/assignments/{id}         → update()
//   DELETE /api/kaprodi/assignments/{id}         → destroy()
//   GET    /api/kaprodi/assignments/{id}/pengajuan-kompen → pengajuan per assignment

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/assignment_model.dart';
import '../models/pengajuan_model.dart';


class KaprodiService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── GET semua assignment yang dibuat kaprodi yang login ──────────────────
  // GET /api/kaprodi/assignments
  Future<List<AssignmentModel>> getAssignments(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/kaprodi/assignments'),
      headers: _headers(token),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List)
          .map((e) => AssignmentModel.fromJson(e))
          .toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil data assignment');
  }

  // ─── GET detail 1 assignment ───────────────────────────────────────────────
  // GET /api/kaprodi/assignments/{id}
  Future<AssignmentModel> getDetailAssignment(String token, String id) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/kaprodi/assignments/$id'),
      headers: _headers(token),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return AssignmentModel.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Assignment tidak ditemukan');
  }

  // ─── BUAT assignment baru ──────────────────────────────────────────────────
  // POST /api/kaprodi/assignments
  // Body: judul, deskripsi, jam_kompen, tanggal_mulai, tanggal_selesai
  Future<Map<String, dynamic>> buatAssignment(
    String token, {
    required String judul,
    required String deskripsi,
    required int jamKompen,
    required String tanggalMulai,   // format: "2025-01-15"
    required String tanggalSelesai, // format: "2025-01-22"
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/kaprodi/assignments'),
      headers: _headers(token),
      body: jsonEncode({
        'judul': judul,
        'deskripsi': deskripsi,
        'jam_kompen': jamKompen,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
      }),
    );
    return jsonDecode(res.body);
    // response: { success: true, message: '...', data: {...} }
  }

  // ─── EDIT assignment ───────────────────────────────────────────────────────
  // PUT /api/kaprodi/assignments/{id}
  Future<Map<String, dynamic>> editAssignment(
    String token,
    String id, {
    String? judul,
    String? deskripsi,
    int? jamKompen,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? status,
  }) async {
    final Map<String, dynamic> payload = {};
    if (judul != null) payload['judul'] = judul;
    if (deskripsi != null) payload['deskripsi'] = deskripsi;
    if (jamKompen != null) payload['jam_kompen'] = jamKompen;
    if (tanggalMulai != null) payload['tanggal_mulai'] = tanggalMulai;
    if (tanggalSelesai != null) payload['tanggal_selesai'] = tanggalSelesai;
    if (status != null) payload['status'] = status;

    final res = await http.put(
      Uri.parse('$_baseUrl/kaprodi/assignments/$id'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
    // response: { success: true, message: '...', data: {...} }
  }

  // ─── HAPUS assignment ──────────────────────────────────────────────────────
  // DELETE /api/kaprodi/assignments/{id}
  Future<Map<String, dynamic>> hapusAssignment(
      String token, String id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/kaprodi/assignments/$id'),
      headers: _headers(token),
    );
    return jsonDecode(res.body);
    // response: { success: true, message: 'Assignment berhasil dihapus selamanya!' }
  }

  // ─── GET daftar pengajuan per assignment ───────────────────────────────────
  // GET /api/kaprodi/assignments/{id}/pengajuan-kompen
  Future<List<PengajuanModel>> getPelamarByAssignment(
      String token, String assignmentId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/kaprodi/assignments/$assignmentId/pengajuan-kompen'),
      headers: _headers(token),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List)
          .map((e) => PengajuanModel.fromJson(e))
          .toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil daftar pelamar');
  }
}