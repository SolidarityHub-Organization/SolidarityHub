import 'dart:convert';
import 'package:solidarityhub/models/donation.dart';
import 'api_general_service.dart';

class VolunteerService {
  static Future<List<Volunteer>> fetchVolunteers() async {
    final response = await ApiService.get('volunteers');
    List<Volunteer> volunteers = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      volunteers = data.map((item) => Volunteer.fromJson(item as Map<String, dynamic>)).toList();
    }

    return volunteers;
  }

  static Future<List<Map<String, dynamic>>> fetchFilteredVolunteerSkillsCount(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final url = 'skills/volunteer-counts?fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';
    final response = await ApiService.get(url);
    List<Map<String, dynamic>> volunteers = [];

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);
      volunteers = data.entries.map((entry) => {'item1': entry.key, 'item2': entry.value}).toList();
    }

    return volunteers;
  }
}
