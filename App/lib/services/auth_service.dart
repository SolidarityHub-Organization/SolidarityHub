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


  static Future<http.Response> register(Map<String, dynamic> data) async {
    final url = Uri.parse('http://localhost:5170/api/v1/signup');

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

  static Future<bool> emailExists(String email) async {
    final url = Uri.parse('http://localhost:5170/api/v1/login');

    final Map<String, dynamic> data = {
      'email': email,
      'password': "passworddep906897lbhjfprueba",
    };

    final response = await http.post(url,
    headers: {
    'Content-Type': 'application/json',
    },
        body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['role'] == "exists";
    } else {
      throw Exception('Error al verificar email: ${response.statusCode}');
    }
    }

}