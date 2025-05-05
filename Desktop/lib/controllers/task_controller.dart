import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/task_table_controller.dart';

class TaskController {
  final TaskTableController tableController;
  final BuildContext context;
  bool get isLoading => tableController.isLoading;

  TaskController({required this.tableController, required this.context});

  static Future<void> loadData(TaskTableController tableController) async {
    await tableController.fetchTasks(() {});
  }
}
