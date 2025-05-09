import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_dialog_controller.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
import 'package:solidarityhub/models/task.dart';

class AutoAssignerDialog extends StatefulWidget {
  final VoidCallback onTasksUpdated;
  final List<TaskWithDetails> tasks;

  const AutoAssignerDialog({super.key, required this.tasks, required this.onTasksUpdated});

  @override
  State<AutoAssignerDialog> createState() => _AutoAssignerDialogState();
}

class _AutoAssignerDialogState extends State<AutoAssignerDialog> {
  late final AutoAssignerDialogController controller;

  @override
  void initState() {
    super.initState();
    controller = AutoAssignerDialogController(tasks: widget.tasks, onTasksUpdated: widget.onTasksUpdated);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto Asignar Tareas'),
      content: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AssignmentStrategyType>(
              value: controller.selectedStrategy,
              decoration: const InputDecoration(labelText: 'Estrategia de Asignación'),
              items:
                  AssignmentStrategyType.values.map((strategy) {
                    return DropdownMenuItem(
                      value: strategy,
                      child: Text(strategy.name[0].toUpperCase() + strategy.name.substring(1)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    controller.setStrategy(value);
                  });
                }
              },
            ),
            TextFormField(
              controller: controller.numberController,
              decoration: const InputDecoration(labelText: 'Voluntarios por Tarea'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                if (num == null || num <= 0) {
                  return 'Introduce un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: controller.affectedTasksNotifier,
              builder: (context, value, child) {
                return Text(
                  'Se actualizarán los voluntarios de $value tareas.',
                  style: TextStyle(color: Colors.grey[700]),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final success = await controller.assignTasks(context);
            if (success && mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}

Future<void> showAutoAssignerDialog(
  BuildContext context,
  List<TaskWithDetails> tasks,
  VoidCallback onTasksUpdated,
) async {
  await showDialog(
    context: context,
    builder: (context) => AutoAssignerDialog(tasks: tasks, onTasksUpdated: onTasksUpdated),
  );
}
