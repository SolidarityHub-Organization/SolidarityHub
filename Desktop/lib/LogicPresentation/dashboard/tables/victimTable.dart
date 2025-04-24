import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/victimServices.dart';

class VictimsTab extends StatefulWidget {
  final String selectedPeriod;

  const VictimsTab({Key? key, required this.selectedPeriod}) : super(key: key);

  @override
  _VictimsTabState createState() => _VictimsTabState();
}

class _VictimsTabState extends State<VictimsTab> {
  late Future<List<Map<String, dynamic>>> _victimNeedsFuture;
  final VictimService _victimService = VictimService('http://localhost:5170');

  @override
  void initState() {
    super.initState();
    _victimNeedsFuture =
        _victimService.fetchVictimCountByDate(); // Usar el método correcto
  }

  List<BarChartGroupData> generateBarGroups(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['num'].toDouble(),
            color: Colors.blue,
            width: 15,
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> generatePieSections(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((entry) {
      return PieChartSectionData(
        value: entry['num'].toDouble(),
        title: '${entry['num']}',
        color: Colors.primaries[entry.hashCode % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _victimService.fetchVictimCountByDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final data = snapshot.data!;

          // Validar que los datos no estén vacíos
          if (data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Ordenar los datos por fecha
          final sortedData =
              data..sort((a, b) => a['date'].compareTo(b['date']));

          // Crear los puntos para el gráfico de líneas
          final lineSpots =
              sortedData
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      entry.key.toDouble(),
                      entry.value['num'] != null
                          ? entry.value['num'].toDouble()
                          : 0.0, // Manejar valores nulos
                    ),
                  )
                  .toList();

          // Generar datos para gráficos de barras y pastel
          final barGroups = generateBarGroups(sortedData);
          final pieSections = generatePieSections(sortedData);

          return SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Afectados y sus necesidades',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                // Gráfico de líneas
                Padding(
                  padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 100.0),
                  child: SizedBox(
                    height: 400,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.3),
                            ),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        minY: 0, // Asegurar que el eje Y comience desde cero
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, // Intervalo de 1 en el eje Y
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value
                                      .toInt()
                                      .toString(), // Mostrar sin decimales
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < lineSpots.length) {
                                  // Mostrar solo las fechas correspondientes a los puntos
                                  return Text(
                                    sortedData[index]['date'],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              interval: 1, // Mostrar solo fechas de los puntos
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                ),
                // Gráfico de barras
                SizedBox(
                  height: 500,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60.0, 0, 30.0, 100.0),
                    child: BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < sortedData.length) {
                                  return Text(
                                    sortedData[index]['date'],
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.red,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final index = group.x.toInt();
                              if (index >= 0 && index < sortedData.length) {
                                return BarTooltipItem(
                                  '${sortedData[index]['date']}: ${rod.toY.toInt()}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Gráfico de pastel
                SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0, 60.0, 20.0),
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
