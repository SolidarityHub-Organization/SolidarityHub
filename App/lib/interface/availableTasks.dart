import 'package:flutter/material.dart';
import '../controllers/availableTasksController.dart';
import '../models/task_post.dart';
import '../models/task_card_creator.dart';

class AvailableTasksScreen extends StatefulWidget {
  final int id;
  const AvailableTasksScreen({super.key, required this.id});

  @override
  State<AvailableTasksScreen> createState() => _AvailableTasksScreenState();
}

class _AvailableTasksScreenState extends State<AvailableTasksScreen> {
  Set<int> _disabledTasks = {};

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
        future: AvailableTasksController.fetchPendingTasks(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
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
              final isDisabled = _disabledTasks.contains(task.id);

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
                            child: ElevatedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () async {
                                await AvailableTasksController.declineTask(widget.id, task.id);
                                setState(() {
                                  _disabledTasks.add(task.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Tarea rechazada')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                'Rechazar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () async {
                                await AvailableTasksController.acceptTask(widget.id, task.id);
                                setState(() {
                                  _disabledTasks.add(task.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Tarea aceptada')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                '¡Quiero ir!',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
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