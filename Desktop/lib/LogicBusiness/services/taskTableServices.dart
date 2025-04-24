import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskTableService {
  final String baseUrl;

  TaskTableService(this.baseUrl);

  Future<Map<String, dynamic>> fetchTaskTypeCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/tasks/states/count'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load task type count');
    }
  }

  Future<Map<String, dynamic>> fetchAllTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/tasks/states/count'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load task type count');
    }
  }
}
