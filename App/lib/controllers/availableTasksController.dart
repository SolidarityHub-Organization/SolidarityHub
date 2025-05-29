import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task_post.dart';

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

  static Future<void> acceptTask({
    required BuildContext context,
    required int taskId,
    required String taskName,
    required int volunteerId,
    required VoidCallback onSuccess,
  }) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/$volunteerId/$taskId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state': 'Assigned'}),
    );

    if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has aceptado la tarea: $taskName')),
      );
      onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar la tarea: ${response.body}')),
      );
      throw Exception('Error al aceptar tarea');
    }
  }

  static Future<void> declineTask({
    required BuildContext context,
    required int taskId,
    required String taskName,
    required int volunteerId,
    required VoidCallback onSuccess,
  }) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/$volunteerId/$taskId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state': 'Cancelled'}),
    );

    if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has rechazado la tarea: $taskName')),
      );
      onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar la tarea: ${response.body}')),
      );
      throw Exception('Error al rechazar tarea');
    }
  }


  static Future<void> unsubscribe({
    required BuildContext context,
    required int taskId,
    required String taskName,
    required int volunteerId,
    required VoidCallback onSuccess,
  }) async {
    final url = Uri.parse('http://localhost:5170/api/v1/tasks/assigned-to-volunteer/$volunteerId/$taskId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state': 'Cancelled'}),
    );

    if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has desinscrito de la tarea: $taskName')),
      );
      onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desinscribirse de la tarea')),
      );
      throw Exception('Error al desinscribirse: ${response.body}');
    }
  }

}
