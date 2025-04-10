import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicBusiness/services/generalServices.dart';
import 'package:solidarityhub/LogicBusiness/services/task_services.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'dart:convert';

import 'package:solidarityhub/LogicPresentation/tasks/create_task.dart';

class Taskstable extends StatefulWidget {
  const Taskstable({super.key});

  @override
  State<Taskstable> createState() => _TaskstableState();
}

class _TaskstableState extends State<Taskstable> {
  GeneralService generalService = GeneralService(
    'http://localhost:5170/api/v1',
  );
  TaskService taskService = TaskService('http://localhost:5170/api/v1');
  List<TaskWithDetails> tasks = [];
  bool isLoading = true;
  Map<int, String> taskAddresses = {};

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // TODO: Create a new endpoint to get all tasks without having to loop calls for the location endpoint
  Future<void> _loadTaskAddresses() async {
    for (var task in tasks) {
      try {
        final locationResponse = await http.get(
          Uri.parse(
            'http://localhost:5170/api/v1/locations/${task.locationId}',
          ),
        );

        if (locationResponse.statusCode == 200) {
          final locationData = json.decode(locationResponse.body);
          final double lat = locationData['latitude'];
          final double lon = locationData['longitude'];

          final address = await generalService.getAddressFromLatLon(lat, lon);

          setState(() {
            taskAddresses[task.id] = address;
          });
        }
      } catch (e) {
        setState(() {
          taskAddresses[task.id] = 'Dirección no disponible';
        });
      }
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5170/api/v1/tasks-with-details'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          tasks =
              data
                  .map((taskJson) => TaskWithDetails.fromJson(taskJson))
                  .toList();
          isLoading = false;
        });

        _loadTaskAddresses();
      } else {
        throw Exception('Error al obtener las tareas: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTask(TaskWithDetails task) async {
    // Show confirmation dialog
    final bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: Text(
                  '¿Está seguro de que desea eliminar la tarea "${task.name}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      setState(() {
        isLoading = true;
      });

      final result = await taskService.deleteTask(task.id);

      await _fetchTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la tarea: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Crea y asigna tareas a voluntarios',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showCreateTaskModal(context, () {
                    _fetchTasks();
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
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(
                child: Text(
                  'No hay tareas disponibles.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        task.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Sin prioridad",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Sin estado",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    taskAddresses[task.id]?.startsWith(
                                              'Error',
                                            ) ==
                                            true
                                        ? 'Dirección desconocida'
                                        : taskAddresses[task.id] ??
                                            'Cargando dirección...',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    task.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Habilidades requeridas:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...[].map<Widget>((skill) {
                                    return Text(
                                      '- $skill',
                                      style: const TextStyle(fontSize: 14),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Asignado a:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        task.assignedVolunteers.isNotEmpty
                                            ? task.assignedVolunteers
                                                .map(
                                                  (volunteer) =>
                                                      '${volunteer.name} ${volunteer.surname}',
                                                )
                                                .join(', ')
                                            : 'Sin asignar',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showCreateTaskModal(context, () {
                                      _fetchTasks();
                                    }, task);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Editar'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _deleteTask(task);
                                    _fetchTasks();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
