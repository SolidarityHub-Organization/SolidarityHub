import 'package:flutter/material.dart';
import '../models/task_post.dart';
import '../services/fetch_tasks.dart';
import '../models/task_card_creator.dart';
import '../controllers/availableTasksController.dart';

class TaskListScreen extends StatefulWidget {
  final int id;

  const TaskListScreen({super.key, required this.id});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = TaskService.fetchAssignedTasks(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text("Lista de tareas asignadas"),
        elevation: 0,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          } else {
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return const Center(
                child: Text("No tienes tareas asignadas.", style: TextStyle(color: Colors.white)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          TaskCard(task: task),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              AvailableTasksController.unsubscribe(
                                context: context,
                                taskId: task.id,
                                volunteerId: widget.id,
                                onSuccess: () {
                                  setState(() {
                                    _loadTasks(); // actualiza la lista
                                  });
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text(
                              "Desinscribirse",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
