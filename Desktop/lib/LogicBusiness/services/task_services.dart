import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskService {
  final String baseUrl;

  TaskService(this.baseUrl);

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
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/map/tasks-with-location'),
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
