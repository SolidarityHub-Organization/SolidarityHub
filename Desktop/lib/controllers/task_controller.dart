import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/task_table_controller.dart';
import 'package:solidarityhub/widgets/ui/snack_bar.dart';

class TaskController {
  final TaskTableController tableController;
  final BuildContext context;
  bool get isLoading => tableController.isLoading;

  TaskController({required this.tableController, required this.context});

  static Future<void> loadData(TaskTableController tableController) async {
    try {
      await tableController.fetchTasks(() {});
    } catch (e) {
      AppSnackBar.show(message: 'Tarea eliminada con éxito', type: SnackBarType.info);
    }
  }
}
