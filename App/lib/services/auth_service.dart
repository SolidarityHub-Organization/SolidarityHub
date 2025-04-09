import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('https://localhost:5170/api/v1/login');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> register(String email, String password) async {
    final url = Uri.parse('https://localhost:5170/api/v1/login');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }
}