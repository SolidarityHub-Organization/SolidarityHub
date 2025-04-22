import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solidarityhub/LogicPresentation/tasks/tasks.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Añade un margen general
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLineChart('Asignado', assignedSpots, Colors.blue),
                      const SizedBox(height: 20),
                      _buildLineChart('Pendiente', pendingSpots, Colors.orange),
                      const SizedBox(height: 20),
                      _buildLineChart(
                        'En progreso',
                        inProgressSpots,
                        Colors.purple,
                      ),
                      const SizedBox(height: 20),
                      _buildLineChart(
                        'Completado',
                        completedSpots,
                        Colors.green,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex:
                                3, // Aumenta el espacio para el gráfico de tortas
                            child: SizedBox(
                              height: 300, // Aumenta la altura del gráfico
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
                                      radius: 60, // Aumenta el radio
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
                                      radius: 60, // Aumenta el radio
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value:
                                          data
                                              .map(
                                                (e) => e['inProgress'] as int,
                                              )
                                              .reduce((a, b) => a + b)
                                              .toDouble(),
                                      title: 'En progreso',
                                      color: Colors.purple,
                                      radius: 60, // Aumenta el radio
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
                                      radius: 60, // Aumenta el radio
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // Reduce el espacio entre el gráfico y los recuadros
                          Expanded(
                            flex: 2, // Reduce el espacio para los recuadros
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 160.0, // Margen derecho
                                top: 40.0, // Margen superior
                              ),
                              child: Column(
                                children: [
                                  _buildStyledInfoCard(
                                    'Tareas Asignadas',
                                    data
                                        .map((e) => e['assigned'] as int)
                                        .reduce((a, b) => a + b)
                                        .toString(),
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStyledInfoCard(
                                    'Tareas Completadas',
                                    data
                                        .map((e) => e['completed'] as int)
                                        .reduce((a, b) => a + b)
                                        .toString(),
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Taskstable(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),

                          label: const Text(
                            'Manejar tareas',
                            style: TextStyle(fontSize: 20),
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
      ),
    );
  }

  Widget _buildLineChart(String title, List<FlSpot> spots, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Margen izquierdo
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Margen izquierdo
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(
                        0.3,
                      ), // Área sombreada con transparencia
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Ocultar números del eje vertical izquierdo
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:
                          true, // Mostrar números en el eje vertical derecho
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Ocultar números del eje horizontal superior
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildStyledInfoCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4), // Sombra hacia abajo
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
