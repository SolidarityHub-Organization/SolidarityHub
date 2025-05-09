import 'package:flutter/material.dart';
import 'package:solidarityhub/services/location_external_services.dart';
import 'package:solidarityhub/services/location_services.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/models/task_table.dart';
import 'package:solidarityhub/models/task.dart';

class TaskTableController {
  final ValueNotifier<List<TaskWithDetails>> tasksNotifier = ValueNotifier<List<TaskWithDetails>>([]);
  final ValueNotifier<List<TaskWithDetails>> filteredTasksNotifier = ValueNotifier<List<TaskWithDetails>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<Map<int, String>> addressesNotifier = ValueNotifier<Map<int, String>>({});

  final ValueNotifier<String> nameFilterNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> addressFilterNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> statusFilterNotifier = ValueNotifier<String>('Todos');
  final ValueNotifier<String> priorityFilterNotifier = ValueNotifier<String>('Todas');

  final ValueNotifier<String> sortFieldNotifier = ValueNotifier<String>('name');
  final ValueNotifier<bool> sortAscendingNotifier = ValueNotifier<bool>(true);

  final ValueNotifier<List<TaskTableColumnData>> columnsNotifier = ValueNotifier<List<TaskTableColumnData>>([]);

  final Map<int, Future<String?>> _pendingAddressFetches = {};
  final Map<int, _CachedAddress> _addressCache = {};

  List<TaskWithDetails> get tasks => tasksNotifier.value;
  List<TaskWithDetails> get filteredTasks => filteredTasksNotifier.value;
  bool get isLoading => isLoadingNotifier.value;
  Map<int, String> get taskAddresses => addressesNotifier.value;

  String get nameFilter => nameFilterNotifier.value;
  String get addressFilter => addressFilterNotifier.value;
  String get statusFilter => statusFilterNotifier.value;
  String get priorityFilter => priorityFilterNotifier.value;

  String get sortField => sortFieldNotifier.value;
  bool get sortAscending => sortAscendingNotifier.value;

  List<TaskTableColumnData> get columns => columnsNotifier.value;

  set nameFilter(String value) {
    nameFilterNotifier.value = value;
    applyFilters();
  }

  set addressFilter(String value) {
    addressFilterNotifier.value = value;
    applyFilters();
  }

  set statusFilter(String value) {
    statusFilterNotifier.value = value;
    applyFilters();
  }

  set priorityFilter(String value) {
    priorityFilterNotifier.value = value;
    applyFilters();
  }

  set sortField(String value) {
    sortFieldNotifier.value = value;
    _sortTasks();
  }

  set sortAscending(bool value) {
    sortAscendingNotifier.value = value;
    _sortTasks();
  }

  TaskTableController() {
    _initColumns();

    nameFilterNotifier.addListener(applyFilters);
    addressFilterNotifier.addListener(applyFilters);
    statusFilterNotifier.addListener(applyFilters);
    priorityFilterNotifier.addListener(applyFilters);

    sortFieldNotifier.addListener(_sortTasks);
    sortAscendingNotifier.addListener(_sortTasks);
  }

  void dispose() {
    nameFilterNotifier.dispose();
    addressFilterNotifier.dispose();
    statusFilterNotifier.dispose();
    priorityFilterNotifier.dispose();
    sortFieldNotifier.dispose();
    sortAscendingNotifier.dispose();
    tasksNotifier.dispose();
    filteredTasksNotifier.dispose();
    isLoadingNotifier.dispose();
    addressesNotifier.dispose();
    columnsNotifier.dispose();
  }

  void _initColumns() {
    columnsNotifier.value = [
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

  Future<void> fetchAddresses([List<int>? specificTaskIds]) async {
    if (filteredTasks.isEmpty) return;

    final tasksToFetch = specificTaskIds ?? filteredTasks.map((task) => task.id).toList();
    Map<int, String> addresses = Map.from(addressesNotifier.value);

    // First set all to loading state and update UI
    for (final taskId in tasksToFetch) {
      if (!addresses.containsKey(taskId) ||
          (addresses[taskId]?.startsWith('Error') == true) ||
          addresses[taskId] == 'Dirección no disponible') {
        addresses[taskId] = 'Cargando dirección...';
      }
    }

    // Update UI with loading indicators
    addressesNotifier.value = Map.from(addresses);

    // Now fetch each address one by one
    for (final taskId in tasksToFetch) {
      // Skip if already fetching
      if (_pendingAddressFetches.containsKey(taskId)) continue;

      // Skip if we have a valid address
      if (addresses.containsKey(taskId) &&
          !addresses[taskId]!.startsWith('Error') &&
          addresses[taskId] != 'Dirección no disponible' &&
          addresses[taskId] != 'Cargando dirección...') {
        continue;
      }

      // Check cache
      if (_addressCache.containsKey(taskId)) {
        final cached = _addressCache[taskId]!;
        if (DateTime.now().difference(cached.timestamp).inHours < 1) {
          addresses[taskId] = cached.address;
          addressesNotifier.value = Map.from(addresses); // Update UI immediately with cached value
          continue;
        }
      }

      // Fetch the address
      _pendingAddressFetches[taskId] = _fetchSingleAddress(taskId);

      // Handle the result
      _pendingAddressFetches[taskId]!.then((address) {
        final updatedAddresses = Map<int, String>.from(addressesNotifier.value);

        if (address != null) {
          updatedAddresses[taskId] = address;
          _addressCache[taskId] = _CachedAddress(address);
        } else {
          updatedAddresses[taskId] = 'Dirección no disponible';
        }

        _pendingAddressFetches.remove(taskId);
        addressesNotifier.value = updatedAddresses; // Update UI with the new address
      });
    }
  }

  Future<String?> _fetchSingleAddress(int taskId) async {
    try {
      // Primero busca en las tareas filtradas
      TaskWithDetails? task;
      try {
        task = filteredTasks.firstWhere((task) => task.id == taskId);
      } catch (e) {
        // Si no encuentra en filtradas, busca en todas las tareas
        task = tasks.firstWhere((task) => task.id == taskId, orElse: () => throw Exception('Tarea no encontrada'));
      }

      if (task.location == null) {
        // Si la tarea no tiene ubicación, intentamos buscarla en el servicio
        try {
          final locationResponse = await LocationServices.fetchLocationById(task.locationId);

          if (locationResponse.isNotEmpty) {
            final double lat = locationResponse['latitude'];
            final double lon = locationResponse['longitude'];

            final address = await LocationExternalServices.getAddressFromLatLon(lat, lon);
            return address;
          } else {
            return 'Dirección no disponible';
          }
        } catch (e) {
          return 'Dirección no disponible';
        }
      }

      final address = await LocationExternalServices.getAddressFromLatLon(
        task.location!.latitude,
        task.location!.longitude,
      );

      return address;
    } catch (e) {
      return 'Dirección no disponible';
    }
  }

  Future<void> fetchAddressForTask(int taskId) async {
    await fetchAddresses([taskId]);
  }

  Future<void> loadTaskAddresses([Function? onTaskChanged]) async {
    Map<int, String> addresses = Map.from(addressesNotifier.value);

    for (var task in tasks) {
      try {
        addresses[task.id] = 'Cargando dirección...';
        addressesNotifier.value = Map.from(addresses);

        if (onTaskChanged != null) {
          onTaskChanged();
        }

        final locationResponse = await LocationServices.fetchLocationById(task.locationId);

        if (locationResponse.isNotEmpty) {
          final double lat = locationResponse['latitude'];
          final double lon = locationResponse['longitude'];

          final address = await LocationExternalServices.getAddressFromLatLon(lat, lon);
          addresses[task.id] = address;

          addressesNotifier.value = Map.from(addresses);

          if (onTaskChanged != null) {
            onTaskChanged();
          }
        }
      } catch (e) {
        addresses[task.id] = 'Dirección no disponible';
        addressesNotifier.value = Map.from(addresses);

        if (onTaskChanged != null) {
          onTaskChanged();
        }
      }
    }

    applyFilters();
  }

  Future<void> fetchTasks([Function? onTaskChanged]) async {
    isLoadingNotifier.value = true;

    final tasksData = await TaskServices.fetchAllTasksWithDetails();
    final List<TaskWithDetails> loadedTasks = tasksData.map((taskData) => TaskWithDetails.fromJson(taskData)).toList();

    tasksNotifier.value = loadedTasks;

    Map<int, String> addresses = {};

    addressesNotifier.value = addresses;

    applyFilters();

    isLoadingNotifier.value = false;

    loadTaskAddresses(onTaskChanged);
  }

  void _sortTasks() {
    List<TaskWithDetails> sorted = List.from(filteredTasksNotifier.value);

    sorted.sort((a, b) {
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
            comparison = 1;
          } else if (b.endDate == null) {
            comparison = -1;
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

    filteredTasksNotifier.value = sorted;
  }

  void applyFilters() {
    final filteredList =
        tasks.where((task) {
          final nameMatches = nameFilter.isEmpty || task.name.toLowerCase().contains(nameFilter.toLowerCase());

          final address = taskAddresses[task.id] ?? '';
          final addressMatches = addressFilter.isEmpty || address.toLowerCase().contains(addressFilter.toLowerCase());

          final statusMatches = statusFilter == 'Todos' || getTaskStatus(task) == statusFilter;

          final priorityMatches = priorityFilter == 'Todas' || getTaskPriority(task) == priorityFilter;

          return nameMatches && addressMatches && statusMatches && priorityMatches;
        }).toList();

    filteredTasksNotifier.value = filteredList;
    _sortTasks();
  }

  String getTaskStatus(TaskWithDetails task) {
    return 'Pendiente';
  }

  String getTaskPriority(TaskWithDetails task) {
    return task.adminId != null ? 'Alta' : 'Media';
  }

  Future<void> deleteTask(TaskWithDetails task, [Function? onComplete]) async {
    isLoadingNotifier.value = true;

    try {
      await TaskServices.deleteTask(task.id);
      await fetchTasks();
      if (onComplete != null) {
        onComplete();
      }
    } catch (e) {
      isLoadingNotifier.value = false;
      rethrow;
    }
  }

  void reorderColumn(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<TaskTableColumnData> updatedColumns = List.from(columns);
    final TaskTableColumnData item = updatedColumns.removeAt(oldIndex);
    updatedColumns.insert(newIndex, item);

    columnsNotifier.value = updatedColumns;
  }

  void updateColumnWidths(int columnIndex, double newWidth, int nextColumnIndex, double nextWidth) {
    final List<TaskTableColumnData> updatedColumns = List.from(columnsNotifier.value);
    updatedColumns[columnIndex].width = newWidth;
    updatedColumns[nextColumnIndex].width = nextWidth;
    columnsNotifier.value = updatedColumns;
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

class _CachedAddress {
  final String address;
  final DateTime timestamp;

  _CachedAddress(this.address) : timestamp = DateTime.now();
}
