import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/widgets/common/snack_bar.dart';

class AutoAssignerDialogController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController(text: '1');
  final ValueNotifier<int> affectedTasksNotifier = ValueNotifier(0);

  AssignmentStrategyType selectedStrategy = AssignmentStrategyType.proximidad;
  int volunteersPerTask = 1;
  final Set<TaskWithDetails> selectedTasks = {};
  late AutoAssigner _autoAssigner;

  final List<TaskWithDetails> tasks;
  final VoidCallback onTasksUpdated;

  AutoAssignerDialogController({required this.tasks, required this.onTasksUpdated}) {
    numberController.addListener(updateAffectedTasks);
    updateAffectedTasks();
    _autoAssigner = AutoAssigner(selectedStrategy);
  }

  void dispose() {
    numberController.removeListener(updateAffectedTasks);
    numberController.dispose();
    affectedTasksNotifier.dispose();
  }

  void updateAffectedTasks() {
    final value = int.tryParse(numberController.text);
    if (value == null || value <= 0) {
      affectedTasksNotifier.value = 0;
      return;
    }

    final count = selectedTasks.where((task) => (task.assignedVolunteers.length) < value).length;
    affectedTasksNotifier.value = count;
  }

  Future<bool> assignTasks(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      if (selectedTasks.isEmpty) {
        AppSnackBar.show(
          context: context,
          message: 'Por favor, selecciona al menos una tarea.',
          type: SnackBarType.error,
        );
        return false;
      }

      volunteersPerTask = int.parse(numberController.text);

      try {
        int potentiallyAffectedTasks =
            selectedTasks.where((task) => task.assignedVolunteers.length < volunteersPerTask).length;

        await _autoAssigner.assignTasks(
          selectedTasks.toList(),
          await VolunteerServices.fetchVolunteersWithDetails(),
          volunteersPerTask,
        );

        onTasksUpdated();

        // Mostrar SnackBar con opción de deshacer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asignación completada. Se procesaron $potentiallyAffectedTasks tareas.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () async {
                try {
                  await _autoAssigner.undoAssignment();
                  onTasksUpdated();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignación deshecha')));
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error al deshacer la asignación: ${e.toString()}')));
                }
              },
            ),
          ),
        );

        return true;
      } catch (e) {
        AppSnackBar.show(
          context: context,
          message: 'Error al asignar voluntarios: ${e.toString()}',
          type: SnackBarType.error,
          duration: const Duration(seconds: 6),
        );
        return false;
      }
    }
    return false;
  }

  void setStrategy(AssignmentStrategyType strategy) {
    selectedStrategy = strategy;
    _autoAssigner.setStrategy(strategy);
  }
}
