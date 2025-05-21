import 'package:flutter/material.dart';
import '../controllers/availableTasksController.dart';
import '../models/task_post.dart';
import '../models/task_card_creator.dart';
import '../models/button_creator.dart';
import '../models/custom_form_builder.dart';

class AvailableTasksScreen extends StatelessWidget {
  final int id;
  const AvailableTasksScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.red,
        title: const Text(
          'TAREAS DISPONIBLES',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Task>>(
        future: AvailableTasksController.fetchPendingTasks(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: \${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay tareas disponibles.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TaskCard(task: task),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildCustomButton(
                              'Rechazar',
                                  () {
                                AvailableTasksController.declineTask(id, task.id);
                              },
                              backgroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildCustomButton(
                              '¡Quiero ir!',
                                  () {
                                AvailableTasksController.acceptTask(id, task.id);
                              },
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
