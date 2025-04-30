import 'dart:convert';
import 'package:http/http.dart' as http;

class VolunteerService {
  final String baseUrl;

  VolunteerService(this.baseUrl);

  /*
  Future<List<Map<String, dynamic>>> fetchVolunteerSkillsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/skills/volunteer-counts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }
  */

  Future<List<Map<String, dynamic>>> fetchFilteredVolunteerSkillsCount(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/skills/volunteer-counts'
        '?fromDate=${startDate.toIso8601String()}'
        '&toDate=${endDate.toIso8601String()}',
      ),
    );
    
    if (response.statusCode == 200) {
      // Convert dictionary to list
      final Map<String, dynamic> data = json.decode(response.body);
      return data.entries.map((entry) => {
        'item1': entry.key,
        'item2': entry.value,
      }).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load filtered volunteer skills count');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/map/volunteers-with-location'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((location) {
          return {
            'id': location['id'],
            'name': location['name'],
            'latitude': location['latitude'],
            'longitude': location['longitude'],
            'type': location['type'],
          };
        }).toList();
      } else {
        print('Error al obtener las ubicaciones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');
      return [];
    }
  }
}
