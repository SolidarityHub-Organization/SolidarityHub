import 'package:flutter/material.dart';
import '../models/task_post.dart';
import '../services/fetch_tasks.dart';
import '../models/task_card_creator.dart';
import '../services/fetch_tasks.dart';

class TaskListScreen extends StatelessWidget {
  final int id;

  const TaskListScreen({super.key, required this.id});

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
        future: TaskServices.fetchAssignedTasks(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else {
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return const Center(child: Text("No tienes tareas asignadas.", style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(task: tasks[index]);
              },
            );
          }
        },
      ),
    );
  }
}
