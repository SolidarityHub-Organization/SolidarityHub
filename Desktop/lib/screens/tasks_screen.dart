import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_controller.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';
import 'package:solidarityhub/widgets/task_table/create_task.dart';
import 'package:solidarityhub/widgets/task_table/auto_assigner_dialog.dart';
import 'package:solidarityhub/widgets/task_table/task_filter_panel.dart';
import 'package:solidarityhub/widgets/task_table/task_table.dart';

const Color kPrimaryRed = Color(0xFFF44336);
const double kButtonHorizontal = 13.0;
const double kButtonVertical = 16.0;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskTableController _tableController = TaskTableController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await TaskController.loadData(_tableController);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Gestión de Tareas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Crea y asigna tareas a voluntarios', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showAutoAssignerDialog(context, _tableController.tasks, () {
                          _loadTasks();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: kButtonHorizontal, vertical: kButtonVertical),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Auto Asignar', style: TextStyle(fontSize: 16)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showCreateTaskModal(context, () {
                          _loadTasks();
                        }, null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: kButtonHorizontal, vertical: kButtonVertical),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Nueva Tarea', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TaskFilterPanel(controller: _tableController, onFilterChanged: () => setState(() {})),
            const SizedBox(height: 16),
            _tableController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tableController.tasks.isEmpty
                ? const Center(
                  child: Text('No hay tareas disponibles.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
                : Expanded(child: TaskTable(controller: _tableController, onTaskChanged: _loadTasks)),
          ],
        ),
      ),
    );
  }
}
