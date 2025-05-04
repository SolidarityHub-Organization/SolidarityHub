import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicBusiness/handlers/auto_assigner.dart';
import 'package:solidarityhub/LogicBusiness/services/coordenadasServices.dart';
import 'package:solidarityhub/LogicBusiness/services/volunteer_service.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPresentation/tasks/controllers/task_table_controller.dart';
import 'package:solidarityhub/LogicPresentation/tasks/create_task.dart';
import 'package:solidarityhub/LogicPresentation/tasks/widgets/task_filter_panel.dart';
import 'package:solidarityhub/LogicPresentation/tasks/widgets/task_table.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskTableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TaskTableController(
      coordenadasService: CoordenadasService('http://localhost:5170/api/v1'),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _controller.fetchTasks(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las tareas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Gestión de Tareas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Gestión de Tareas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Crea y asigna tareas a voluntarios',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        AutoAssigner(BalancedAssignmentStrategy()).assignTasks(
                          _controller.tasks,
                          await VolunteerService.fetchVolunteers(),
                          2,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.0,
                          vertical: 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text(
                        'Auto Asignar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showCreateTaskModal(context, () {
                          _loadData();
                        }, null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.0,
                          vertical: 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Nueva Tarea',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TaskFilterPanel(
              controller: _controller,
              onFilterChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),
            _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.tasks.isEmpty
                ? const Center(
                  child: Text(
                    'No hay tareas disponibles.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                : Expanded(
                  child: TaskTable(
                    controller: _controller,
                    onTaskChanged: () => setState(() {}),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
