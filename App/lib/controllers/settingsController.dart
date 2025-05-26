import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../interface/dataModification.dart';
import '../models/dialogs.dart';
import '../services/fetch_tasks.dart'; // TaskService
import '../models/task_post.dart';

class SettingsController {
  VoidCallback onDataModificationPressed(BuildContext context, int id, String role) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DataModification(id: id, role: role),
        ),
      );
    };
  }

  Future<void> onDeleteAccountPressed(BuildContext context, int id, String role) async {
    if (role == 'voluntario') {
      try {
        // Verificar si tiene tareas asignadas
        final List<Task> assignedTasks = await TaskService.fetchAssignedTasks(id);
        if (assignedTasks.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No puedes eliminar tu cuenta. Tienes ${assignedTasks.length} tareas activas.')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al comprobar tareas asignadas')),
        );
        return;
      }
    }

    // Mostrar diálogo de confirmación SOLO si no tiene tareas
    await showDeleteConfirmationDialog(context, () async {
      final url = Uri.parse(role == 'voluntario'
          ? 'http://localhost:5170/api/v1/volunteers/$id'
          : 'http://localhost:5170/api/v1/victims/$id');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta eliminada correctamente')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar cuenta')),
        );
      }
    });
  }
}
