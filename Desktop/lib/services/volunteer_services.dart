import 'dart:convert';
import 'package:solidarityhub/controllers/general_controller.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'api_services.dart';

class VolunteerServices {
  static Future<List<Volunteer>> fetchVolunteersWithDetails() async {
    final response = await ApiServices.get('volunteers-with-details');
    List<Volunteer> volunteers = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      volunteers = data.map((item) => Volunteer.fromJson(item as Map<String, dynamic>)).toList();
    }
    return volunteers;
  }

  static Future<List<Volunteer>> fetchVolunteers() async {
    final response = await ApiServices.get('volunteers');
    List<Volunteer> volunteers = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      volunteers = data.map((e) => Volunteer.fromJson(e)).toList();
    }

    return volunteers;
  }

  static Future<List<Map<String, dynamic>>> fetchFilteredVolunteerSkillsCount(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final url = 'skills/volunteer-counts?fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';
    final response = await ApiServices.get(url);
    List<Map<String, dynamic>> volunteers = [];

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);
      volunteers = data.entries.map((entry) => {'item1': entry.key, 'item2': entry.value}).toList();
    }

    return volunteers;
  }

  static Future<int> fetchVolunteerCount(DateTime startDate, DateTime endDate) async {
    final adjustedStartDate = GeneralController.adjustEndDate(startDate);
    final adjustedEndDate = GeneralController.adjustEndDate(endDate);
    int count = 0;

    final url =
        'volunteers/count'
        '?fromDate=${adjustedStartDate.toIso8601String()}'
        '&toDate=${adjustedEndDate.toIso8601String()}';
    final response = await ApiServices.get(url);

    if (response.statusCode.ok) {
      if (response.body.isEmpty) {
        count = 0;
      }

      count = int.parse(response.body);
    } else {
      throw Exception('Error al obtener voluntarios filtrados: ${response.statusCode}, Respuesta: ${response.body}');
    }

    return count;
  }
}
