import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPresentation/tasks/controllers/task_table_controller.dart';
import 'package:solidarityhub/LogicPresentation/tasks/create_task.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);

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
                      children: [
                        Text('Descripción: ${task.description}'),
                        const SizedBox(height: 8),
                        Text(
                          'Dirección: ${controller.taskAddresses[task.id]?.startsWith('Error') == true ? 'Dirección desconocida' : controller.taskAddresses[task.id] ?? 'Cargando dirección...'}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
            );
          },
          child: Text(task.name, overflow: TextOverflow.ellipsis),
        );

      case 'description':
        return Text(task.description, overflow: TextOverflow.ellipsis);

      case 'address':
        return Text(
          controller.taskAddresses[task.id]?.startsWith('Error') == true
              ? 'Dirección desconocida'
              : controller.taskAddresses[task.id] ?? 'Cargando dirección...',
          overflow: TextOverflow.ellipsis,
        );

      case 'start_date':
        return _buildDateCell(task.startDate);

      case 'end_date':
        return _buildDateCell(task.endDate);

      case 'status':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: controller.getStatusColor(controller.getTaskStatus(task)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            controller.getTaskStatus(task),
            style: const TextStyle(color: Colors.white),
          ),
        );

      case 'priority':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: controller.getPriorityColor(
              controller.getTaskPriority(task),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            controller.getTaskPriority(task),
            style: const TextStyle(color: Colors.white),
          ),
        );

      case 'volunteers':
        return Text(
          task.assignedVolunteers.isNotEmpty
              ? task.assignedVolunteers
                  .map((volunteer) => '${volunteer.name} ${volunteer.surname}')
                  .join(', ')
              : 'Sin asignar',
          overflow: TextOverflow.ellipsis,
        );

      case 'actions':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
              onPressed: () {
                showCreateTaskModal(context, () {
                  onTaskChanged();
                }, task);
              },
              tooltip: 'Editar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteConfirmationDialog(context),
              tooltip: 'Eliminar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );

      default:
        return const Text('');
    }
  }

  Widget _buildDateCell(DateTime? date) {
    if (date == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Por determinar',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        DateFormat('dd/MM/yyyy').format(date),
        style: const TextStyle(color: Colors.black),
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
                content: Text(
                  '¿Está seguro de que desea eliminar la tarea "${task.name}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
        ) ??
        false;

    if (confirm) {
      try {
        await controller.deleteTask(task, () {
          onTaskChanged();
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea eliminada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar la tarea: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
