import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('https://tuservidor.com/api/login'); // ← Cambia esta URL por la tuya

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return response;
  }
}