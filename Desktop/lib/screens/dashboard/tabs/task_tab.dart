import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solidarityhub/screens/map.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'dart:math' as math;
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';

class TaskTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const TaskTab({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  _TaskTabState createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  late Future<Map<String, dynamic>> _taskTypeCount;
  late Future<List<Map<String, dynamic>>> _paginatedTasks;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _taskTypeCount = TaskServices.fetchTaskTypeCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );

    setState(() {
      _accumulatedTasks.clear();
      _pageNumber = 1;
      _totalPages = 1;
    });

    _paginatedTasks = getPaginatedTasks(_pageNumber, _pageSize).then((result) {
      setState(() {
        _accumulatedTasks.addAll(result['tasks']);
        _pageNumber++;
        _totalPages = result['totalPages'];
      });
      return _accumulatedTasks;
    });
  }

  int _pageNumber = 1;
  final int _pageSize = 10; // number tasks retrieved per request
  int _totalPages = 0;
  List<Map<String, dynamic>> _accumulatedTasks = [];

  Future<Map<String, dynamic>> getPaginatedTasks(int pageNumber, int pageSize) async {
    final response = await TaskServices.fetchDateFilteredPaginatedTasks(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
      pageNumber,
      pageSize,
    );
    
    var itemsKey = response.containsKey('Items') ? 'Items' : 'items';
    var totalPagesKey = response.containsKey('TotalPages') ? 'TotalPages' : 'totalPages';
    
    List<Map<String, dynamic>> tasks = [];
    if (response.containsKey(itemsKey) && response[itemsKey] is List) {
      tasks = (response[itemsKey] as List)
          .map((task) => task as Map<String, dynamic>)
          .toList();

      
      print("Tasks list: $tasks");
      
      for (var task in tasks) {
        print("Task: $task");
      }
      

      var totalCountKey = response.containsKey('TotalCount') ? 'TotalCount' : 'totalCount';
      var pageNumberKey = response.containsKey('PageNumber') ? 'PageNumber' : 'pageNumber';
      var pageSizeKey = response.containsKey('PageSize') ? 'PageSize' : 'pageSize';
      var totalPagesKey = response.containsKey('TotalPages') ? 'TotalPages' : 'totalPages';

      print("Total Count: ${response[totalCountKey]}");
      print("Current Page: ${response[pageNumberKey]}");
      print("Page Size: ${response[pageSizeKey]}");
      print("Total Pages: ${response[totalPagesKey]}");


      // setState() not inside this method to avoid the UI flickering after clicking the "Cargar más" button because it loses its scroll position
      
    } else {
      print("No items found in response: ${response.keys}");
    }
    
    return {
      'tasks': tasks,
      'totalPages': response[totalPagesKey] ?? 1,
    };
  }

  String? _selectedUrgency;
  String? _selectedState;
  String? _selectedZone;

  @override
  void didUpdateWidget(covariant TaskTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _loadData();
      });
    }
  }

  ScrollController? _mainVerticalController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TwoDimensionalScrollWidget(
          onVerticalControllerReady: (ctrl) => _mainVerticalController = ctrl,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(800.0, constraints.maxWidth),
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicWidth(
              child: Container(
                width: math.max(800.0, constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Distribución de Tareas por Estado',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 70),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _taskTypeCount,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error al cargar los datos'));
                          } else {
                            final data = snapshot.data!;
                            final List<PieChartSectionData> pieSections = _generatePieSections(data);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: SizedBox(
                                        height: 300,
                                        child: PieChart(
                                          PieChartData(sections: pieSections, sectionsSpace: 4, centerSpaceRadius: 50),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          _buildStyledInfoCard(
                                            'Tareas Asignadas',
                                            data['Assigned'].toString(),
                                            _getColorForTaskType('Assigned'),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildStyledInfoCard(
                                            'Tareas Pendientes',
                                            data['Pending'].toString(),
                                            _getColorForTaskType('Pending'),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildStyledInfoCard(
                                            'Tareas Completadas',
                                            data['Completed'].toString(),
                                            _getColorForTaskType('Completed'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                      Text('Lista de Tareas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Nivel de Urgencia',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                    value: _selectedUrgency,
                                    items:
                                        ['Sin seleccionar', 'Alto', 'Medio', 'Bajo', 'Crítico', 'Desconocido']
                                            .map(
                                              (urgency) => DropdownMenuItem(
                                                value: urgency == 'Sin seleccionar' ? null : urgency,
                                                child: Text(urgency),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUrgency = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Estado',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                    value: _selectedState,
                                    items:
                                        ['Sin seleccionar', 'Asignado', 'Pendiente', 'Completado', 'Desconocido']
                                            .map(
                                              (state) => DropdownMenuItem(
                                                value: state == 'Sin seleccionar' ? null : state,
                                                child: Text(state),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedState = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Zona Afectada',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                    value: _selectedZone,
                                    items:
                                        ['Sin seleccionar', 'Zona de Inundación A', 'Sin zona']
                                            .map(
                                              (zone) => DropdownMenuItem(
                                                value: zone == 'Sin seleccionar' ? null : zone,
                                                child: Text(zone),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedZone = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedUrgency = null;
                                    _selectedState = null;
                                    _selectedZone = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                child: const Text('Borrar Filtros'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _paginatedTasks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error al cargar las tareas'));
                          } else {
                            final tasks = snapshot.data!.map((task) {
                              return {
                                'name': task['name'] ?? 'Sin nombre',
                                'urgency_level': task['urgency_level'] ?? 'Desconocido',
                                'state': task['state'] ?? 'Desconocido',
                                'affected_zone': task['affected_zone'],
                                'latitude': task['latitude'] ?? 0.0,
                                'longitude': task['longitude'] ?? 0.0,
                              };
                            }).where(
                              (task) =>
                                  (_selectedUrgency == null || task['urgency_level'] == _selectedUrgency) &&
                                  (_selectedState == null || task['state'] == _selectedState) &&
                                  (_selectedZone == null ||
                                      (_selectedZone == 'Sin zona' && task['affected_zone'] == null) ||
                                      (task['affected_zone']?['name'] == _selectedZone)),
                            ).toList();
                            
                            if (tasks.isEmpty) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                elevation: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(24.0),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: 48, color: Colors.grey[600]),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Sin datos disponibles',
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'No hay tareas que coincidan con los filtros seleccionados',
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    final affectedZoneName = task['affected_zone']?['name'] ?? 'Sin zona';

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                      elevation: 4,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(16.0),
                                        title: Text(
                                          task['name'] ?? 'Sin nombre',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Urgencia: ${task['urgency_level'] ?? 'Desconocido'}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              'Estado: ${task['state'] ?? 'Desconocido'}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            Text('Zona afectada: $affectedZoneName', style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                        trailing: task['affected_zone'] != null
                                          ? IconButton(
                                              icon: const Icon(Icons.location_on, color: Colors.red),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MapScreen(
                                                      lat: task['latitude'],
                                                      lng: task['longitude'],
                                                      initialZoom: 16.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : null,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: (_pageNumber > _totalPages)
                                      ? null
                                      : () async {
                                          final oldOffset = _mainVerticalController?.offset ?? 0.0;
                                          
                                          final result = await getPaginatedTasks(_pageNumber, _pageSize);
                                          
                                          setState(() {
                                            _accumulatedTasks.addAll(result['tasks']);
                                            _pageNumber++;
                                            _totalPages = result['totalPages'];
                                          });
                                          
                                          // wait for frame render, then jump to old offset
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            if (_mainVerticalController?.hasClients ?? false) {
                                              _mainVerticalController!.jumpTo(oldOffset);
                                            }
                                          });
                                        },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Cargar más'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, dynamic> data) {
    
    final Map<String, dynamic> normalizedData = {};
    data.forEach((key, value) {
      String normalizedKey;
      
      String lowerKey = key.toLowerCase();
      
      if (lowerKey.contains('assign') || lowerKey.contains('asign')) {
        normalizedKey = 'Assigned';
      } else if (lowerKey.contains('pend') || lowerKey == 'por hacer') {
        normalizedKey = 'Pending';
      } else if (lowerKey.contains('comple') || lowerKey.contains('termin')) {
        normalizedKey = 'Completed';
      } else {
        normalizedKey = key;
      }
      
      normalizedData[normalizedKey] = (normalizedData[normalizedKey] ?? 0) + (value ?? 0);
    });
    
    final filteredData = Map<String, dynamic>.from(normalizedData)
      ..removeWhere((key, value) => key == 'Unknown' || key == 'Desconocido');
    
    bool hasData = filteredData.values.any((value) => (value as num) > 0);
    
    if (!hasData) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Sin datos\ndisponibles',
          color: Colors.grey,
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ];
    }

    return filteredData.entries.map((entry) {
      final value = (entry.value as int).toDouble();
      final translatedKey = _translateTaskType(entry.key);

      final String truncatedKey = _truncateWithEllipsis(translatedKey, 10);

      return PieChartSectionData(
        value: value,
        title: '$truncatedKey\n$value',
        color: _getColorForTaskType(entry.key),
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    return (text.length <= maxLength) ? text : '${text.substring(0, maxLength)}...';
  }

  String _translateTaskType(String taskType) {
    switch (taskType) {
      case 'Assigned':
        return 'Asignadas';
      case 'Pending':
        return 'Pendientes';
      case 'Completed':
        return 'Completadas';
      default:
        return 'Desconocido';
    }
  }

  Color _getColorForTaskType(String taskType) {
    switch (taskType) {
      case 'Assigned':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStyledInfoCard(String title, String value, Color color) {
    final displayValue = value == 'null' ? '0' : value;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0, right: 100.0, top: 0.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8.0),
          Text(displayValue, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
