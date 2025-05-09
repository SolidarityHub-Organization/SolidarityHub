import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/services/volunteer_services.dart';

class AutoAssignerDialogController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController(text: '1');
  final ValueNotifier<int> affectedTasksNotifier = ValueNotifier(0);

  AssignmentStrategyType selectedStrategy = AssignmentStrategyType.proximidad;
  int volunteersPerTask = 1;

  final List<TaskWithDetails> tasks;
  final VoidCallback onTasksUpdated;

  AutoAssignerDialogController({required this.tasks, required this.onTasksUpdated}) {
    numberController.addListener(updateAffectedTasks);
    updateAffectedTasks();
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

    final count = tasks.where((task) => (task.assignedVolunteers.length) < value).length;
    affectedTasksNotifier.value = count;
  }

  Future<bool> assignTasks(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      volunteersPerTask = int.parse(numberController.text);

      await AutoAssigner(
        selectedStrategy,
      ).assignTasks(tasks, await VolunteerServices.fetchVolunteersWithDetails(), volunteersPerTask);

      onTasksUpdated();
      return true;
    }
    return false;
  }

  void setStrategy(AssignmentStrategyType strategy) {
    selectedStrategy = strategy;
  }
}
