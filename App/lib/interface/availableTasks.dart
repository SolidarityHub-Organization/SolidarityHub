import 'package:flutter/material.dart';
import '../controllers/availableTasksController.dart';
import '../models/task_post.dart';
import '../models/task_card_creator_pending.dart';
import '../models/button_creator.dart';
import '../models/custom_form_builder.dart';

class AvailableTasksScreen extends StatefulWidget {
  final int id;
  const AvailableTasksScreen({super.key, required this.id});

  @override
  State<AvailableTasksScreen> createState() => AvailableTasksScreenState();
}

class AvailableTasksScreenState extends State<AvailableTasksScreen> {
  late AvailableTasksController _controller;
  late Future<List<Task>> _tasksFuture;
  List<Task> _tasks = [];
  int _currentTaskIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AvailableTasksController(id: widget.id);
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = AvailableTasksController.fetchPendingTasks(widget.id);
    _tasksFuture.then((tasks) {
      setState(() {
        _tasks = tasks;
        _currentTaskIndex = 0;
      });
    });
  }

  void _handleDecision() {
    setState(() {
      if (_currentTaskIndex < _tasks.length - 1) {
        _currentTaskIndex++;
      } else {
        _tasks = [];
      }
    });
  }

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
        title: const Text('TAREAS DISPONIBLES', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (_tasks.isEmpty) {
            return const Center(child: Text('No hay tareas disponibles.', style: TextStyle(color: Colors.white)));
          }

          final task = _tasks[_currentTaskIndex];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TaskCard(task: task),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: buildCustomButton(
                                    'Rechazar',
                                        () {
                                      AvailableTasksController.declineTask(widget.id, task.id);
                                      _handleDecision();
                                    },
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildCustomButton(
                                    '¡Quiero ir!',
                                        () {
                                      AvailableTasksController.acceptTask(widget.id, task.id);
                                      _handleDecision();
                                    },
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
