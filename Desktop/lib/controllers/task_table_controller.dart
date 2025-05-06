import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/services/coordenadasServices.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/models/task_table.dart';
import 'package:solidarityhub/models/task.dart';

class TaskTableController {
  final CoordenadasService coordenadasService;

  List<TaskWithDetails> tasks = [];
  List<TaskWithDetails> filteredTasks = [];
  bool isLoading = true;
  Map<int, String> taskAddresses = {};

  String nameFilter = '';
  String addressFilter = '';
  String statusFilter = 'Todos';
  String priorityFilter = 'Todas';

  String sortField = 'name';
  bool sortAscending = true;

  List<TaskTableColumnData> columns = [];

  TaskTableController({required this.coordenadasService}) {
    _initColumns();
  }

  void _initColumns() {
    columns = [
      TaskTableColumnData(id: 'name', label: 'Nombre', width: 0.1, tooltip: 'Nombre de la tarea', sortable: true),
      TaskTableColumnData(
        id: 'description',
        label: 'Descripción',
        width: 0.15,
        tooltip: 'Descripción de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'address',
        label: 'Dirección',
        width: 0.15,
        tooltip: 'Dirección de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'start_date',
        label: 'Fecha Inicio',
        width: 0.1,
        tooltip: 'Fecha de inicio de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'end_date',
        label: 'Fecha Fin',
        width: 0.1,
        tooltip: 'Fecha de fin de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'status',
        label: 'Estado',
        width: 0.1,
        tooltip: 'Estado actual de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'priority',
        label: 'Prioridad',
        width: 0.1,
        tooltip: 'Prioridad de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'volunteers',
        label: 'Voluntarios',
        width: 0.1,
        tooltip: 'Voluntarios asignados',
        sortable: false,
      ),
      TaskTableColumnData(
        id: 'actions',
        label: 'Acciones',
        width: 0.1,
        tooltip: 'Acciones disponibles',
        sortable: false,
      ),
    ];
  }

  Future<void> loadTaskAddresses([Function? onTaskChanged]) async {
    for (var task in tasks) {
      try {
        final locationResponse = await http.get(Uri.parse('http://localhost:5170/api/v1/locations/${task.locationId}'));

        if (locationResponse.statusCode == 200) {
          final locationData = json.decode(locationResponse.body);
          final double lat = locationData['latitude'];
          final double lon = locationData['longitude'];

          final address = await coordenadasService.getAddressFromLatLon(lat, lon);
          taskAddresses[task.id] = address;

          applyFilters();
          // Notificar a la UI que los datos han cambiado
          if (onTaskChanged != null) {
            onTaskChanged();
          }
        }
      } catch (e) {
        taskAddresses[task.id] = 'Dirección no disponible';
        applyFilters();
        // Notificar a la UI que los datos han cambiado incluso con error
        if (onTaskChanged != null) {
          onTaskChanged();
        }
      }
    }
  }

  Future<void> fetchTasks([Function? onTaskChanged]) async {
    isLoading = true;

    try {
      final response = await http.get(Uri.parse('http://localhost:5170/api/v1/tasks-with-details'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        tasks = data.map((taskJson) => TaskWithDetails.fromJson(taskJson)).toList();
        filteredTasks = List.from(tasks);

        for (var task in tasks) {
          taskAddresses[task.id] = 'Cargando dirección...';
        }

        _sortTasks();

        // Pasar el callback a loadTaskAddresses para notificar cambios en la UI
        loadTaskAddresses(onTaskChanged);

        isLoading = false;
      } else {
        throw Exception('Error al obtener las tareas: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  void _sortTasks() {
    filteredTasks.sort((a, b) {
      int comparison;

      switch (sortField) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'address':
          final aAddress = taskAddresses[a.id] ?? '';
          final bAddress = taskAddresses[b.id] ?? '';
          comparison = aAddress.compareTo(bAddress);
          break;
        case 'start_date':
          comparison = a.startDate.compareTo(b.startDate);
          break;
        case 'end_date':
          if (a.endDate == null && b.endDate == null) {
            comparison = 0;
          } else if (a.endDate == null) {
            comparison = 1; // Los nulos van al final
          } else if (b.endDate == null) {
            comparison = -1; // Los nulos van al final
          } else {
            comparison = a.endDate!.compareTo(b.endDate!);
          }
          break;
        case 'status':
          comparison = getTaskStatus(a).compareTo(getTaskStatus(b));
          break;
        case 'priority':
          comparison = getTaskPriority(a).compareTo(getTaskPriority(b));
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }

      return sortAscending ? comparison : -comparison;
    });
  }

  void applyFilters() {
    filteredTasks =
        tasks.where((task) {
          final nameMatches = nameFilter.isEmpty || task.name.toLowerCase().contains(nameFilter.toLowerCase());
          final address = taskAddresses[task.id] ?? '';
          final addressMatches = addressFilter.isEmpty || address.toLowerCase().contains(addressFilter.toLowerCase());
          final statusMatches = statusFilter == 'Todos' || getTaskStatus(task) == statusFilter;
          final priorityMatches = priorityFilter == 'Todas' || getTaskPriority(task) == priorityFilter;

          return nameMatches && addressMatches && statusMatches && priorityMatches;
        }).toList();

    _sortTasks();
  }

  String getTaskStatus(TaskWithDetails task) {
    return 'Pendiente';
  }

  String getTaskPriority(TaskWithDetails task) {
    return task.adminId != null ? 'Alta' : 'Media';
  }

  Future<void> deleteTask(TaskWithDetails task, [Function? onComplete]) async {
    isLoading = true;

    try {
      await TaskService.deleteTask(task.id);
      await fetchTasks();
      if (onComplete != null) {
        onComplete();
      }
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  void reorderColumn(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TaskTableColumnData item = columns.removeAt(oldIndex);
    columns.insert(newIndex, item);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completado':
        return Colors.green;
      case 'Pendiente':
        return Colors.blue;
      case 'Asignado':
        return Colors.amber;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
