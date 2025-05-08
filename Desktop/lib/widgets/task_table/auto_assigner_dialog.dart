import 'package:flutter/material.dart';
import 'package:solidarityhub/handlers/auto_assigner.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/models/task.dart';

class AutoAssignerDialog extends StatefulWidget {
    final VoidCallback onTasksUpdated;
  final List<TaskWithDetails> tasks;

  const AutoAssignerDialog({super.key, required this.tasks, required this.onTasksUpdated});

  @override
  State<AutoAssignerDialog> createState() => _AutoAssignerDialogState();
}

class _AutoAssignerDialogState extends State<AutoAssignerDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController(text: '1');
  final ValueNotifier<int> _affectedTasksNotifier = ValueNotifier(0);

  AssignmentStrategyType _selectedStrategy = AssignmentStrategyType.proximidad;
  int _volunteersPerTask = 1;

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_updateAffectedTasks);
    _updateAffectedTasks();
  }

  @override
  void dispose() {
    _numberController.removeListener(_updateAffectedTasks);
    _numberController.dispose();
    _affectedTasksNotifier.dispose();
    super.dispose();
  }

  void _updateAffectedTasks() {
    final value = int.tryParse(_numberController.text);
    if (value == null || value <= 0) {
      _affectedTasksNotifier.value = 0;
      return;
    }

    final count = widget.tasks.where((task) => (task.assignedVolunteers.length) < value).length;
    _affectedTasksNotifier.value = count;
  }

  Future<void> _assignTasks() async {
    if (_formKey.currentState?.validate() ?? false) {
      _volunteersPerTask = int.parse(_numberController.text);

      await AutoAssigner(_selectedStrategy).assignTasks(
        widget.tasks,
        await VolunteerServices.fetchVolunteersWithDetails(),
        _volunteersPerTask,
      );

      widget.onTasksUpdated();

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto Asignar Tareas'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AssignmentStrategyType>(
              value: _selectedStrategy,
              decoration: const InputDecoration(labelText: 'Estrategia de Asignación'),
              items: AssignmentStrategyType.values.map((strategy) {
                return DropdownMenuItem(
                  value: strategy,
                  child: Text(strategy.name[0].toUpperCase() + strategy.name.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStrategy = value;
                  });
                }
              },
            ),
            TextFormField(
              controller: _numberController,
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
              valueListenable: _affectedTasksNotifier,
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _assignTasks,
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}

Future<void> showAutoAssignerDialog(BuildContext context, List<TaskWithDetails> tasks, VoidCallback onTasksUpdated) async {
  await showDialog(
    context: context,
    builder: (context) => AutoAssignerDialog(tasks: tasks, onTasksUpdated: onTasksUpdated),
  );
}
