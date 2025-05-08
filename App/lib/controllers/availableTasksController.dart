import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_post.dart';
import '../services/fetch_tasks.dart';

class AvailableTasksController {
  final int id;

  AvailableTasksController({required this.id});

  static Future<List<Task>> fetchPendingTasks(int volunteerId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/pending/$volunteerId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((taskJson) => Task.fromJson(taskJson)).toList();
    } else {
      throw Exception('Error al cargar tareas asignadas');
    }
  }

  static Future<void> acceptTask(int volunteerId, int taskId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/$volunteerId/$taskId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state':'Assigned'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al aceptar la tarea: ${response.body}');
    }
  }

  static Future<void> declineTask(int volunteerId, int taskId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/$volunteerId/$taskId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state':'Cancelled'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al rechazar la tarea: ${response.body}');
    }
  }
}
