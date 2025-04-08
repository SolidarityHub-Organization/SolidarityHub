import 'dart:convert';
import 'package:http/http.dart' as http;

class VolunteerService {
  final String baseUrl;

  VolunteerService(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchVolunteerSkillsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/skills/volunteer-counts'),
    );

    // Imprime el código de estado y el cuerpo de la respuesta
    print("Voluntarios");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }
}
