import 'package:flutter/material.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/models/task_table.dart';
import 'package:solidarityhub/models/task.dart';

class TaskTableController {
  final ValueNotifier<List<TaskWithDetails>> tasksNotifier = ValueNotifier<List<TaskWithDetails>>([]);
  final ValueNotifier<List<TaskWithDetails>> filteredTasksNotifier = ValueNotifier<List<TaskWithDetails>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(true);

  final ValueNotifier<String> nameFilterNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> statusFilterNotifier = ValueNotifier<String>('Todos');
  final ValueNotifier<String> priorityFilterNotifier = ValueNotifier<String>('Todas');

  final ValueNotifier<String> sortFieldNotifier = ValueNotifier<String>('name');
  final ValueNotifier<bool> sortAscendingNotifier = ValueNotifier<bool>(true);

  final ValueNotifier<List<TaskTableColumnData>> columnsNotifier = ValueNotifier<List<TaskTableColumnData>>([]);

  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> itemsPerPageNotifier = ValueNotifier<int>(10);
  final ValueNotifier<List<TaskWithDetails>> paginatedTasksNotifier = ValueNotifier<List<TaskWithDetails>>([]);
  final ValueNotifier<int> totalPagesNotifier = ValueNotifier<int>(1);

  final Map<int, int> _taskStatuses = {};
  final Map<int, String> _taskPriorities = {};
  TaskWithDetails? _lastDeletedTask;

  List<TaskWithDetails> get tasks => tasksNotifier.value;
  List<TaskWithDetails> get filteredTasks => filteredTasksNotifier.value;
  List<TaskWithDetails> get paginatedTasks => paginatedTasksNotifier.value;
  bool get isLoading => isLoadingNotifier.value;

  String get nameFilter => nameFilterNotifier.value;
  String get statusFilter => statusFilterNotifier.value;
  String get priorityFilter => priorityFilterNotifier.value;

  String get sortField => sortFieldNotifier.value;
  bool get sortAscending => sortAscendingNotifier.value;

  List<TaskTableColumnData> get columns => columnsNotifier.value;

  int get currentPage => currentPageNotifier.value;
  int get itemsPerPage => itemsPerPageNotifier.value;
  int get totalPages => totalPagesNotifier.value;
  int get totalItems => filteredTasks.length;
  set nameFilter(String value) {
    nameFilterNotifier.value = value;
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

  set currentPage(int value) {
    if (value >= 1 && value <= totalPages) {
      currentPageNotifier.value = value;
      _updatePaginatedTasks();
    }
  }

  set itemsPerPage(int value) {
    if (value > 0) {
      itemsPerPageNotifier.value = value;
      currentPageNotifier.value = 1;
      _updatePaginatedTasks();
    }
  }

  TaskTableController() {
    _initColumns();

    nameFilterNotifier.addListener(applyFilters);
    statusFilterNotifier.addListener(applyFilters);
    priorityFilterNotifier.addListener(applyFilters);

    sortFieldNotifier.addListener(_sortTasks);
    sortAscendingNotifier.addListener(_sortTasks);

    filteredTasksNotifier.addListener(_updatePaginatedTasks);
  }
  void dispose() {
    nameFilterNotifier.dispose();
    statusFilterNotifier.dispose();
    priorityFilterNotifier.dispose();
    sortFieldNotifier.dispose();
    sortAscendingNotifier.dispose();
    tasksNotifier.dispose();
    filteredTasksNotifier.dispose();
    isLoadingNotifier.dispose();
    columnsNotifier.dispose();
    currentPageNotifier.dispose();
    itemsPerPageNotifier.dispose();
    paginatedTasksNotifier.dispose();
    totalPagesNotifier.dispose();
  }

  void _initColumns() {
    columnsNotifier.value = [
      TaskTableColumnData(id: 'name', label: 'Nombre', width: 0.15, tooltip: 'Nombre de la tarea', sortable: true),
      TaskTableColumnData(
        id: 'description',
        label: 'Descripción',
        width: 0.30,
        tooltip: 'Descripción de la tarea',
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
        width: 0.07,
        tooltip: 'Estado actual de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'priority',
        label: 'Prioridad',
        width: 0.07,
        tooltip: 'Prioridad de la tarea',
        sortable: true,
      ),
      TaskTableColumnData(
        id: 'volunteers',
        label: 'Voluntarios',
        width: 0.11,
        tooltip: 'Voluntarios asignados',
        sortable: false,
      ),
      TaskTableColumnData(
        id: 'actions',
        label: 'Acciones',
        width: 0.10,
        tooltip: 'Acciones disponibles',
        sortable: false,
      ),
    ];
  }

  Future<void> fetchTasks([Function? onComplete]) async {
    isLoadingNotifier.value = true;

    final tasksData = await TaskServices.fetchAllTasksWithDetails();
    final List<TaskWithDetails> loadedTasks = tasksData.map((taskData) => TaskWithDetails.fromJson(taskData)).toList();

    tasksNotifier.value = loadedTasks;

    await _loadTaskStatusesAndPriorities(loadedTasks);

    applyFilters();

    isLoadingNotifier.value = false;

    if (onComplete != null) {
      onComplete();
    }
  }

  Future<void> _loadTaskStatusesAndPriorities(List<TaskWithDetails> tasks) async {
    _taskStatuses.clear();
    _taskPriorities.clear();

    for (var task in tasks) {
      final status = await TaskServices.getTaskStateById(task.id);
      final taskUrgencyLevel = await TaskServices.fetchMaxUrgencyLevelForTaskAsync(task.id);

      _taskStatuses[task.id] = status;
      _taskPriorities[task.id] = taskUrgencyLevel;
    }
  }

  void _sortTasks() {
    List<TaskWithDetails> sorted = List.from(filteredTasksNotifier.value);

    sorted.sort((a, b) {
      int comparison;

      switch (sortField) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'description':
          comparison = a.description.compareTo(b.description);
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

  void _updatePaginatedTasks() {
    final filteredList = filteredTasksNotifier.value;
    final totalItems = filteredList.length;

    final totalPagesCount = totalItems == 0 ? 1 : (totalItems / itemsPerPage).ceil();
    totalPagesNotifier.value = totalPagesCount;

    if (currentPage > totalPagesCount) {
      currentPageNotifier.value = totalPagesCount;
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);

    if (startIndex < totalItems) {
      paginatedTasksNotifier.value = filteredList.sublist(startIndex, endIndex);
    } else {
      paginatedTasksNotifier.value = [];
    }
  }

  void applyFilters() {
    bool matchesAllFilters(TaskWithDetails task) {
      return (nameFilter.isEmpty || task.name.toLowerCase().contains(nameFilter.toLowerCase())) &&
          (statusFilter == 'Todos' || getTaskStatus(task) == statusFilter) &&
          (priorityFilter == 'Todas' || getTaskPriority(task) == priorityFilter);
    }

    final filteredList = tasks.where(matchesAllFilters).toList();
    filteredTasksNotifier.value = filteredList;
    currentPageNotifier.value = 1;
    _sortTasks();
  }

  void goToFirstPage() {
    currentPage = 1;
  }

  void goToLastPage() {
    currentPage = totalPages;
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      currentPage = currentPage - 1;
    }
  }

  void goToNextPage() {
    if (currentPage < totalPages) {
      currentPage = currentPage + 1;
    }
  }

  void goToPage(int page) {
    currentPage = page;
  }

  bool get canGoToPrevious => currentPage > 1;
  bool get canGoToNext => currentPage < totalPages;

  String getTaskStatus(TaskWithDetails task) {
    final status = _taskStatuses[task.id] ?? 'Desconocido';

    switch (status) {
      case -1:
        return 'Desconocido';
      case 0:
        return 'Asignado';
      case 1:
        return 'Pendiente';
      case 2:
        return 'Completado';
      case 3:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  String getTaskPriority(TaskWithDetails task) {
    return _taskPriorities[task.id] ?? 'Desconocido';
  }

  Future<void> deleteTask(TaskWithDetails task, [Function? onComplete]) async {
    isLoadingNotifier.value = true;
    _lastDeletedTask = task;

    try {
      await TaskServices.deleteTask(task.id);
      await fetchTasks();
      if (onComplete != null) {
        onComplete();
      }
    } catch (e) {
      isLoadingNotifier.value = false;
      _lastDeletedTask = null;
      rethrow;
    }
  }

  Future<void> restoreLastDeletedTask() async {
    if (_lastDeletedTask == null) return;

    try {
      await TaskServices.createTask(
        name: _lastDeletedTask!.name,
        description: _lastDeletedTask!.description,
        selectedVolunteers: _lastDeletedTask!.assignedVolunteers.map((v) => v.id).toList(),
        latitude: _lastDeletedTask!.location?.latitude.toString() ?? '0',
        longitude: _lastDeletedTask!.location?.longitude.toString() ?? '0',
        startDate: _lastDeletedTask!.startDate,
        endDate: _lastDeletedTask!.endDate,
        selectedVictim: _lastDeletedTask!.assignedVictim.map((v) => v.id).toList(),
      );
      await fetchTasks();
      _lastDeletedTask = null;
    } catch (e) {
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
      case 'Crítico':
        return Colors.purple;
      case 'Alto':
        return Colors.red;
      case 'Medio':
        return Colors.orange;
      case 'Bajo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
