import 'dart:convert';
import 'package:solidarityhub/handlers/task_handler.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/services/api_service.dart';

class TaskService {
  static Future<String> createTask({
    required String name,
    required String description,
    required List<int> selectedVolunteers,
    required String latitude,
    required String longitude,
    required DateTime startDate,
    DateTime? endDate,
    List<int>? selectedVictim,
    int? taskId,
  }) async {
    final Map<String, dynamic> taskData = {
      'id': taskId,
      'name': name,
      'description': description,
      'admin_id': null,
      'volunteer_ids': selectedVolunteers,
      'victim_ids': selectedVictim ?? [],
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': {'latitude': latitude, 'longitude': longitude},
    };

    final validationHandler = ValidationHandler();
    final locationHandler = LocationHandler();
    final persistenceHandler = PersistenceHandler();

    validationHandler.setNext(locationHandler).setNext(persistenceHandler);

    return await validationHandler.handle(taskData);
  }

  static Future<void> updateTask(TaskWithDetails task) async {
    final body = {
      'id': task.id,
      'name': task.name,
      'description': task.description,
      'admin_id': task.adminId,
      'location_id': task.locationId,
      'start_date': task.startDate.toIso8601String(),
      'end_date': task.endDate?.toIso8601String(),
      'volunteer_ids': task.assignedVolunteers.map((v) => v.id).toList(),
      'victim_ids': task.assignedVictim.map((v) => v.id).toList(),
    };
    final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: json.encode(body));
    if (!response.statusCode.ok) {
      throw Exception('Failed to update task');
    }
  }

  static Future<Map<String, dynamic>> fetchTaskTypeCount(DateTime startDate, DateTime endDate) async {
    final response = await ApiService.get(
      'tasks/states/count'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load task type count');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllTasks(DateTime startDate, DateTime endDate) async {
    final response = await ApiService.get(
      'tasks/dashboard'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((task) => task as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<String> deleteTask(int id) async {
    final response = await ApiService.delete('tasks/$id');

    if (response.statusCode.ok) {
      return 'Task deleted successfully';
    } else {
      throw Exception('Failed to delete task with id $id');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/map/tasks-with-location'));
      if (response.statusCode.ok) {
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
