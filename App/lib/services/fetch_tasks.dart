import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_post.dart';

class TaskService {
  static Future<List<Task>> fetchAssignedTasks(int volunteerId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/assigned/$volunteerId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((taskJson) => Task.fromJson(taskJson)).toList();
    } else {
      throw Exception('Error al cargar tareas asignadas');
    }
  }
  static Future<List<Task>> fetchPendingTasks(int volunteerId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/pending/$volunteerId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((taskJson) => Task.fromJson(taskJson)).toList();
    } else {
      throw Exception('Error al cargar tareas pendientes');
    }
  }
}
