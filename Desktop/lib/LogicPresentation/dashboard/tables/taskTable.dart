import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/taskTableServices.dart';

class TaskTable extends StatefulWidget {
  const TaskTable({Key? key, required String selectedPeriod}) : super(key: key);

  @override
  _TaskTableState createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  final TaskTableService _taskService = TaskTableService(
    'http://localhost:5170',
  );
  late Future<List<Map<String, dynamic>>> _taskProgressFuture;

  @override
  void initState() {
    super.initState();
    _taskProgressFuture = _fetchTaskProgress();
  }

  Future<List<Map<String, dynamic>>> _fetchTaskProgress() async {
    // Simula datos de evolución de tareas con diferentes estados
    return [
      {
        'date': '2023-01-01',
        'assigned': 12,
        'pending': 8,
        'inProgress': 5,
        'completed': 3,
      },
      {
        'date': '2023-01-02',
        'assigned': 18,
        'pending': 10,
        'inProgress': 6,
        'completed': 5,
      },
      {
        'date': '2023-01-03',
        'assigned': 25,
        'pending': 12,
        'inProgress': 8,
        'completed': 10,
      },
      {
        'date': '2023-01-04',
        'assigned': 22,
        'pending': 10,
        'inProgress': 7,
        'completed': 15,
      },
      {
        'date': '2023-01-05',
        'assigned': 30,
        'pending': 15,
        'inProgress': 10,
        'completed': 20,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Evolución de Tareas por Estado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _taskProgressFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar los datos'));
              } else {
                final data = snapshot.data!;
                final assignedSpots =
                    data
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value['assigned'] as int).toDouble(),
                          ),
                        )
                        .toList();
                final pendingSpots =
                    data
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value['pending'] as int).toDouble(),
                          ),
                        )
                        .toList();
                final inProgressSpots =
                    data
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value['inProgress'] as int).toDouble(),
                          ),
                        )
                        .toList();
                final completedSpots =
                    data
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value['completed'] as int).toDouble(),
                          ),
                        )
                        .toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: assignedSpots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: true),
                            ),
                            LineChartBarData(
                              spots: pendingSpots,
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: true),
                            ),
                            LineChartBarData(
                              spots: inProgressSpots,
                              isCurved: true,
                              color: Colors.purple,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: true),
                            ),
                            LineChartBarData(
                              spots: completedSpots,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: true),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < data.length) {
                                    return Text(
                                      data[value.toInt()]['date'] as String,
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Asignado', Colors.blue),
                        const SizedBox(width: 10),
                        _buildLegendItem('Pendiente', Colors.orange),
                        const SizedBox(width: 10),
                        _buildLegendItem('En progreso', Colors.purple),
                        const SizedBox(width: 10),
                        _buildLegendItem('Completado', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Distribución de Tareas por Estado',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value:
                                  data
                                      .map((e) => e['assigned'] as int)
                                      .reduce((a, b) => a + b)
                                      .toDouble(),
                              title: 'Asignado',
                              color: Colors.blue,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value:
                                  data
                                      .map((e) => e['pending'] as int)
                                      .reduce((a, b) => a + b)
                                      .toDouble(),
                              title: 'Pendiente',
                              color: Colors.orange,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value:
                                  data
                                      .map((e) => e['inProgress'] as int)
                                      .reduce((a, b) => a + b)
                                      .toDouble(),
                              title: 'En progreso',
                              color: Colors.purple,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value:
                                  data
                                      .map((e) => e['completed'] as int)
                                      .reduce((a, b) => a + b)
                                      .toDouble(),
                              title: 'Completado',
                              color: Colors.green,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
