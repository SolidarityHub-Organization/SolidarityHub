import 'dart:convert';
import 'package:http/http.dart' as http;

class GeneralService {
  final String baseUrl;

  GeneralService(this.baseUrl);

  Future<int> fetchVictimCount() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/victims/count'));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }

  Future<int> fetchVolunteerCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/volunteers/count'),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }
}
