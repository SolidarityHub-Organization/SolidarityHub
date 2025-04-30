import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicBusiness/services/coordenadasServices.dart';
import 'package:solidarityhub/LogicBusiness/services/task_services.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'dart:convert';

import 'package:solidarityhub/LogicPresentation/tasks/create_task.dart';

class ColumnData {
  final String id;
  final String label;
  double width;
  final String tooltip;
  final bool sortable;

  ColumnData({
    required this.id,
    required this.label,
    required this.width,
    required this.tooltip,
    required this.sortable,
  });
}

class Taskstable extends StatefulWidget {
  const Taskstable({super.key});

  @override
  State<Taskstable> createState() => _TaskstableState();
}

class _TaskstableState extends State<Taskstable> {
  CoordenadasService coordenadasService = CoordenadasService(
    'http://localhost:5170/api/v1',
  );
  TaskService taskService = TaskService('http://localhost:5170/api/v1');
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

  List<ColumnData> columns = [];

  @override
  void initState() {
    super.initState();
    _initColumns();
    _fetchTasks();
  }

  void _initColumns() {
    columns = [
      ColumnData(
        id: 'name',
        label: 'Nombre',
        width: 0.15,
        tooltip: 'Nombre de la tarea',
        sortable: true,
      ),
      ColumnData(
        id: 'description',
        label: 'Descripción',
        width: 0.2,
        tooltip: 'Descripción de la tarea',
        sortable: true,
      ),
      ColumnData(
        id: 'address',
        label: 'Dirección',
        width: 0.15,
        tooltip: 'Dirección de la tarea',
        sortable: true,
      ),
      ColumnData(
        id: 'status',
        label: 'Estado',
        width: 0.1,
        tooltip: 'Estado actual de la tarea',
        sortable: true,
      ),
      ColumnData(
        id: 'priority',
        label: 'Prioridad',
        width: 0.1,
        tooltip: 'Prioridad de la tarea',
        sortable: true,
      ),
      ColumnData(
        id: 'volunteers',
        label: 'Voluntarios',
        width: 0.2,
        tooltip: 'Voluntarios asignados',
        sortable: false,
      ),
      ColumnData(
        id: 'actions',
        label: 'Acciones',
        width: 0.1,
        tooltip: 'Acciones disponibles',
        sortable: false,
      ),
    ];
  }

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

          final address = await coordenadasService.getAddressFromLatLon(
            lat,
            lon,
          );

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

    _applyFilters();
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
          filteredTasks = List.from(tasks);
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

  void _reorderColumn(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ColumnData item = columns.removeAt(oldIndex);
      columns.insert(newIndex, item);
    });
  }

  Widget _buildDraggableDataTable() {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: _reorderColumn,
        header: Container(
          height: 500,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              children: List.generate(columns.length, (columnIndex) {
                return ReorderableDragStartListener(
                  index: columnIndex,
                  child: _buildColumn(columnIndex),
                );
              }),
            ),
          ),
        ),
        children: <Widget>[],
      ),
    );
  }

  Widget _buildColumn(int columnIndex) {
    final column = columns[columnIndex];
    final width = (MediaQuery.of(context).size.width - 32) * column.width;

    return Container(
      key: ValueKey(column.id),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    column.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (column.sortable)
                  IconButton(
                    icon: Icon(
                      sortField == column.id
                          ? (sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.unfold_more,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        if (sortField == column.id) {
                          sortAscending = !sortAscending;
                        } else {
                          sortField = column.id;
                          sortAscending = true;
                        }
                        _applyFilters();
                      });
                    },
                    tooltip: 'Ordenar por ${column.label}',
                    constraints: const BoxConstraints(
                      maxWidth: 24,
                      maxHeight: 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                // Resize handle in header
                if (columnIndex < columns.length - 1)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        final totalWidth =
                            MediaQuery.of(context).size.width - 32;
                        final delta = details.delta.dx / totalWidth;
                        final minWidth = 0.05;
                        final maxWidth = 0.5;

                        setState(() {
                          final newWidth = columns[columnIndex].width + delta;
                          final nextWidth =
                              columns[columnIndex + 1].width - delta;

                          if (newWidth >= minWidth &&
                              newWidth <= maxWidth &&
                              nextWidth >= minWidth &&
                              nextWidth <= maxWidth) {
                            columns[columnIndex].width = newWidth;
                            columns[columnIndex + 1].width = nextWidth;
                          }
                        });
                      },
                      child: Container(
                        width: 8,
                        height: 24,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 450,
            child: ListView.builder(
              itemCount: filteredTasks.isEmpty ? 1 : filteredTasks.length,
              itemBuilder: (context, rowIndex) {
                if (filteredTasks.isEmpty) {
                  return Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child:
                        columnIndex == 0
                            ? const Text('No se encontraron resultados')
                            : const Text(''),
                  );
                }

                final task = filteredTasks[rowIndex];
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: _buildCellContent(column.id, task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskWithDetails task) async {
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

  void _applyFilters() {
    setState(() {
      filteredTasks =
          tasks.where((task) {
            final nameMatches =
                nameFilter.isEmpty ||
                task.name.toLowerCase().contains(nameFilter.toLowerCase());

            final address = taskAddresses[task.id] ?? '';
            final addressMatches =
                addressFilter.isEmpty ||
                address.toLowerCase().contains(addressFilter.toLowerCase());

            final statusMatches =
                statusFilter == 'Todos' || _getTaskStatus(task) == statusFilter;

            final priorityMatches =
                priorityFilter == 'Todas' ||
                _getTaskPriority(task) == priorityFilter;

            return nameMatches &&
                addressMatches &&
                statusMatches &&
                priorityMatches;
          }).toList();

      _sortTasks();
    });
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
        case 'status':
          comparison = _getTaskStatus(a).compareTo(_getTaskStatus(b));
          break;
        case 'priority':
          comparison = _getTaskPriority(a).compareTo(_getTaskPriority(b));
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }

      return sortAscending ? comparison : -comparison;
    });
  }

  String _getTaskStatus(TaskWithDetails task) {
    return 'Pendiente';
  }

  String _getTaskPriority(TaskWithDetails task) {
    return task.adminId != null ? 'Alta' : 'Media';
  }

  Widget _buildCellContent(String columnId, TaskWithDetails task) {
    switch (columnId) {
      case 'name':
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(task.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descripción: ${task.description}'),
                        const SizedBox(height: 8),
                        Text(
                          'Dirección: ${taskAddresses[task.id]?.startsWith('Error') == true ? 'Dirección desconocida' : taskAddresses[task.id] ?? 'Cargando dirección...'}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
            );
          },
          child: Text(task.name, overflow: TextOverflow.ellipsis),
        );

      case 'description':
        return Text(task.description, overflow: TextOverflow.ellipsis);

      case 'address':
        return Text(
          taskAddresses[task.id]?.startsWith('Error') == true
              ? 'Dirección desconocida'
              : taskAddresses[task.id] ?? 'Cargando dirección...',
          overflow: TextOverflow.ellipsis,
        );

      case 'status':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(_getTaskStatus(task)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getTaskStatus(task),
            style: const TextStyle(color: Colors.white),
          ),
        );

      case 'priority':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPriorityColor(_getTaskPriority(task)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getTaskPriority(task),
            style: const TextStyle(color: Colors.white),
          ),
        );

      case 'volunteers':
        return Text(
          task.assignedVolunteers.isNotEmpty
              ? task.assignedVolunteers
                  .map((volunteer) => '${volunteer.name} ${volunteer.surname}')
                  .join(', ')
              : 'Sin asignar',
          overflow: TextOverflow.ellipsis,
        );

      case 'actions':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
              onPressed: () {
                showCreateTaskModal(context, () {
                  _fetchTasks();
                }, task);
              },
              tooltip: 'Editar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                _deleteTask(task);
              },
              tooltip: 'Eliminar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );

      default:
        return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
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
            ExpansionTile(
              title: const Text('Filtros y Ordenamiento'),
              backgroundColor: Colors.grey[50],
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la tarea',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                nameFilter = value;
                                _applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                addressFilter = value;
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              value: statusFilter,
                              items:
                                  [
                                    'Todos',
                                    'Asignado',
                                    'Pendiente',
                                    'Completado',
                                    'Cancelado',
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    statusFilter = newValue;
                                    _applyFilters();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Prioridad',
                                border: OutlineInputBorder(),
                              ),
                              value: priorityFilter,
                              items:
                                  [
                                    'Todas',
                                    'Alta',
                                    'Media',
                                    'Baja',
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    priorityFilter = newValue;
                                    _applyFilters();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: () {
                              setState(() {
                                sortAscending = !sortAscending;
                                _applyFilters();
                              });
                            },
                            tooltip:
                                sortAscending
                                    ? 'Cambiar a orden descendente'
                                    : 'Cambiar a orden ascendente',
                          ),
                          const Text('Ordenamiento:'),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              'Por ${columns.firstWhere((c) => c.id == sortField).label}',
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                nameFilter = '';
                                addressFilter = '';
                                statusFilter = 'Todos';
                                priorityFilter = 'Todas';
                                sortField = 'name';
                                sortAscending = true;
                                _applyFilters();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpiar filtros'),
                          ),
                        ],
                      ),
                    ],
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
                : Expanded(child: _buildDraggableDataTable()),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  Color _getPriorityColor(String priority) {
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
