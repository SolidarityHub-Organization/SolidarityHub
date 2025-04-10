import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('http://localhost:5170/api/v1/login');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> registerVictims(Map<String, dynamic> data) async {
    final url = Uri.parse('http://localhost:5170/api/v1/victims');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response;
  }

  static Future<http.Response> registerVolunteer(Map<String, dynamic> data) async {
    final url = Uri.parse('http://localhost:5170/api/v1/volunteer');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response;
  }

  static Future<http.Response> sendVolunteerSkill({
    required String volunteerId,
    required String skill,
  }) async {
    final url = Uri.parse('http://localhost:5170/api/v1/volunteerSkill');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'volunteer_id': volunteerId,
        'skill_id': skill,
      }),
    );

    return response;
  }
}