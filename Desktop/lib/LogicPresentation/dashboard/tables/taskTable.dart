import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/taskTableServices.dart';

class TaskTable extends StatefulWidget {
  final String selectedPeriod; // Agregar el parámetro selectedPeriod

  const TaskTable({Key? key, required this.selectedPeriod}) : super(key: key);

  @override
  _TaskTableState createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  final TaskTableService _taskService = TaskTableService(
    'http://localhost:5170',
  );

  // Inicializar el Future correctamente
  late final Future<Map<String, dynamic>> _taskTypeCount =
      _taskService.fetchTaskTypeCount();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              // Centrar el título
              child: Text(
                'Distribución de Tareas por Estado',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 70), // Margen inferior agregado
            FutureBuilder<Map<String, dynamic>>(
              future: _taskTypeCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los datos'));
                } else {
                  final data = snapshot.data!;
                  final List<PieChartSectionData> pieSections =
                      _generatePieSections(data);

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
                                PieChartData(
                                  sections: pieSections,
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                ),
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
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      final value = (entry.value as int).toDouble();
      final translatedKey = _translateTaskType(entry.key); // Traducir el estado
      return PieChartSectionData(
        value: value,
        title: '$translatedKey\n$value', // Usar el estado traducido
        color: _getColorForTaskType(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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
      margin: const EdgeInsets.only(
        bottom: 16.0,
        right: 100.0,
        top: 30.0,
      ), // Margen derecho agregado
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
