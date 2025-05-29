import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';
import 'package:solidarityhub/widgets/task_table/create_task.dart';
import 'package:intl/intl.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/widgets/common/snack_bar.dart';

class TaskTableCell extends StatelessWidget {
  final String columnId;
  final TaskWithDetails task;
  final TaskTableController controller;
  final VoidCallback onTaskChanged;

  const TaskTableCell({
    super.key,
    required this.columnId,
    required this.task,
    required this.controller,
    required this.onTaskChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (columnId) {
      case 'name':
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(task.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('Descripción: ${task.description}')],
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                  ),
            );
          },
          child: Center(child: Text(task.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
        );
      case 'description':
        return Center(child: Text(task.description, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center));

      case 'start_date':
        return Center(child: _buildDateCell(task.startDate));

      case 'end_date':
        return Center(child: _buildDateCell(task.endDate));

      case 'status':
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: const BoxConstraints(minWidth: 90),
            decoration: BoxDecoration(
              color: controller.getStatusColor(controller.getTaskStatus(task)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))],
            ),
            child: Text(
              controller.getTaskStatus(task),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        );

      case 'priority':
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: const BoxConstraints(minWidth: 70),
            decoration: BoxDecoration(
              color: controller.getPriorityColor(controller.getTaskPriority(task)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))],
            ),
            child: Text(
              controller.getTaskPriority(task),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        );

      case 'volunteers':
        return Center(
          child: Text(
            task.assignedVolunteers.isNotEmpty
                ? task.assignedVolunteers.map((volunteer) => '${volunteer.name} ${volunteer.surname}').join(', ')
                : 'Sin asignar',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );

      case 'actions':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      showCreateTaskModal(context, () {
                        onTaskChanged();
                      }, task);
                    },
                    tooltip: 'Editar',
                    splashRadius: 20,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    tooltip: 'Eliminar',
                    splashRadius: 20,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const Center(child: Text(''));
    }
  }

  Widget _buildDateCell(DateTime? date) {
    if (date == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Por determinar',
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('HH:mm').format(date),
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: Text('¿Está seguro de que desea eliminar la tarea "${task.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Eliminar'),
                  ),
                ],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
        ) ??
        false;

    if (confirm) {
      try {
        await controller.deleteTask(task, () {
          onTaskChanged();
        });

        // Mostrar SnackBar con opción de deshacer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tarea eliminada'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () async {
                try {
                  await controller.restoreLastDeletedTask();
                  onTaskChanged();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea restaurada')));
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error al restaurar la tarea: ${e.toString()}')));
                }
              },
            ),
          ),
        );
      } catch (e) {
        AppSnackBar.show(
          context: context,
          message: 'Error al eliminar la tarea: ${e.toString()}',
          type: SnackBarType.info,
        );
      }
    }
  }
}
