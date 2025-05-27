import 'dart:convert';
import 'package:solidarityhub/controllers/tasks/task_handler.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/services/api_services.dart';

class TaskServices {
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

    return await processTaskRequest(taskData);
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
    final response = await ApiServices.put('tasks/${task.id}', body: body);

    if (!response.statusCode.ok) {
      throw Exception('Failed to update task');
    }
  }

  static Future<Map<String, dynamic>> fetchTaskTypeCount(DateTime startDate, DateTime endDate) async {
    final response = await ApiServices.get(
      'tasks/states/count'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );
    Map<String, dynamic> tasks = {};

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);
      tasks = data.map((key, value) => MapEntry(key, value as int));
    }

    return tasks;
  }

  static Future<List<Map<String, dynamic>>> fetchAllTasks(DateTime startDate, DateTime endDate) async {
    final response = await ApiServices.get(
      'tasks/dashboard'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );
    List<Map<String, dynamic>> tasks = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      tasks = data.map((task) => task as Map<String, dynamic>).toList();
    }

    return tasks;
  }

  static Future<Map<String, dynamic>> fetchDateFilteredPaginatedTasks(DateTime startDate, DateTime endDate, int page, int size) async {
    final response = await ApiServices.get(
      'tasks/dashboard/paginated'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}'
      '&page=$page'
      '&size=$size',
    );
    Map<String, dynamic> result = {};

    if (response.statusCode.ok) {
      result = json.decode(response.body);
    }

    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchAllTasksWithDetails() async {
    final response = await ApiServices.get('tasks-with-details');
    List<Map<String, dynamic>> tasks = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      tasks = data.map((task) => task as Map<String, dynamic>).toList();
    }

    return tasks;
  }

  static Future<String> fetchMaxUrgencyLevelForTaskAsync(int taskId) async {
    final response = await ApiServices.get('tasks/$taskId/urgency_level');
    String urgencyLevel = '';

    if (response.statusCode.ok) {
      urgencyLevel = json.decode(response.body);
    }

    return urgencyLevel;
  }

  static Future<String> deleteTask(int id) async {
    final response = await ApiServices.delete('tasks/$id');

    if (response.statusCode.ok) {
      return 'Task deleted successfully';
    } else {
      throw Exception('Failed to delete task with id $id');
    }
  }

  static Future<int> fetchTaskCountByStateFiltered(String state, DateTime startDate, DateTime endDate) async {
    final String params = 'fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';
    final response = await ApiServices.get('tasks/states/$state/count?$params');
    int count = 0;

    if (response.statusCode.ok) {
      count = json.decode(response.body);
    }

    return count;
  }

  static Future<int> getTaskStateById(int id) async {
    final response = await ApiServices.get('tasks/states/$id');
    int state = -1;

    if (response.statusCode.ok) {
      state = json.decode(response.body);
    }

    return state;
  }
}
