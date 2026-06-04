import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// lib/services/api_services.dart

class ApiService {
  // Ganti pakai URL Ngrok permanenmu atau IP 10.0.2.2 jika pakai emulator
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  // Fungsi untuk mengambil profil dari MySQL lewat Laravel
  Future<UserModel?> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json', // Wajib! Seperti di Postman kemarin
          'Authorization': 'Bearer $token', // Memasukkan token hasil login
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Mengambil data di dalam object 'user' dari JSON Laravel
        return UserModel.fromJson(responseData['user']);
      } else {
        print('Gagal ambil data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error koneksi ke Laravel: $e');
      return null;
    }
  }
}