import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solidarityhub/LogicPresentation/map/map.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'dart:math' as math;
import 'package:solidarityhub/LogicPresentation/common_widgets/two_dimensional_scroll_widget.dart';

class TaskTable extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const TaskTable({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  _TaskTableState createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    // Ajustar la fecha fin para incluir todo el día (23:59:59.999)
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    // Ajustar la fecha inicio para comenzar al principio del día (00:00:00.000)
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  // Inicializar el Future correctamente
  late final Future<Map<String, dynamic>> _taskTypeCount = TaskService.fetchTaskTypeCount(
    _adjustStartDate(widget.fechaInicio),
    _adjustEndDate(widget.fechaFin),
  );
  late final Future<List<Map<String, dynamic>>> _allTasks = TaskService.fetchAllTasks(
    _adjustStartDate(widget.fechaInicio),
    _adjustEndDate(widget.fechaFin),
  );

  String? _selectedUrgency;
  String? _selectedState;
  String? _selectedZone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TwoDimensionalScrollWidget(
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
                        future: _allTasks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error al cargar las tareas'));
                          } else {
                            final tasks =
                                snapshot.data!
                                    .where(
                                      (task) =>
                                          (_selectedUrgency == null || task['urgency_level'] == _selectedUrgency) &&
                                          (_selectedState == null || task['state'] == _selectedState) &&
                                          (_selectedZone == null ||
                                              (_selectedZone == 'Sin zona' && task['affected_zone'] == null) ||
                                              (task['affected_zone']?['name'] == _selectedZone)),
                                    )
                                    .toList();
                            return ListView.builder(
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
                                    trailing:
                                        task['affected_zone'] != null
                                            ? IconButton(
                                              icon: const Icon(Icons.location_on, color: Colors.red),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const MapScreen()),
                                                );
                                              },
                                            )
                                            : null,
                                  ),
                                );
                              },
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
    // filter out unknown tasks
    final filteredData = Map<String, dynamic>.from(data)
      ..removeWhere((key, value) => key == 'Unknown' || key == 'Desconocido');

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
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
