import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Membaca Base URL dari file .env Flutter kamu
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  /// Fungsi untuk mengirim request login ke backend Laravel
  Future<Map<String, dynamic>?> attemptLogin(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // Memastikan Laravel selalu merespon dengan format JSON
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      // Jika password & username benar (Status 200 OK)
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      // Jika error (misal 401 Unauthorized), kita passing body error-nya untuk dibaca Controller
      return jsonDecode(response.body);
    } catch (e) {
      print('Error pada AuthService: $e');
      return null;
    }
  }
}