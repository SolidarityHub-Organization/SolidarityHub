import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/models/donation.dart';

class VolunteerService {
  static String baseUrl = 'http://localhost:5170/api/v1';

  static Future<List<Volunteer>> fetchVolunteers() async {
    final url = Uri.parse('$baseUrl/volunteers');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Volunteer.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error fetching volunteers: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFilteredVolunteerSkillsCount(
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
      return data.entries.map((entry) => {'item1': entry.key, 'item2': entry.value}).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load filtered volunteer skills count');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/map/volunteers-with-location'));
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
