import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskTableService {
  final String baseUrl;

  TaskTableService(this.baseUrl);

  Future<Map<String, dynamic>> fetchTaskTypeCount(DateTime startDate, DateTime endDate) async {
    print(
      'Fetching task type count with query parameters: '
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/tasks/states/count'
        '?fromDate=${startDate.toIso8601String()}'
        '&toDate=${endDate.toIso8601String()}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load task type count');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllTasks(DateTime startDate, DateTime endDate) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/tasks/dashboard'
        '?fromDate=${startDate.toIso8601String()}'
        '&toDate=${endDate.toIso8601String()}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((task) => task as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<String> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return "Task deleted successfully";
    } else {
      throw Exception('Failed to delete task with id $id');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/map/tasks-with-location'));
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
