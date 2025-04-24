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
  final VictimService _victimService = VictimService('http://localhost:5170');

  // Inicializar los Futures directamente
  late final Future<List<Map<String, dynamic>>> _victimCountFuture =
      _victimService.fetchVictimCountByDate();
  late final Future<List<Map<String, dynamic>>> _victimNeedsFuture =
      _victimService.fetchVictimCountByType();

  List<BarChartGroupData> generateBarGroups(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: (entry.value['num'] ?? 0).toDouble(), // Manejar valores nulos
            color: Colors.red, // Cambiar color a rojo
            width: 30, // Aumentar el grosor de las barras
            borderRadius: BorderRadius.circular(
              4,
            ), // Reducir redondez de bordes
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> generatePieSections(
    List<Map<String, dynamic>> data,
    List<Color> uniqueColors, // Pasar la lista de colores única
  ) {
    final total = data.fold<int>(
      0,
      (sum, entry) => sum + ((entry['num'] ?? 0) as int), // Calcular el total
    );

    return data.asMap().entries.map((entry) {
      final value = (entry.value['num'] ?? 0).toDouble();
      final percentage =
          total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
      return PieChartSectionData(
        value: value,
        title: '$percentage%', // Mostrar porcentaje
        color: uniqueColors[entry.key], // Usar un color único
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget buildLegend(
    List<Map<String, dynamic>> data,
    List<Color> uniqueColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          data.asMap().entries.map((entry) {
            final color =
                uniqueColors[entry.key]; // Usar el mismo color que el gráfico
            final label =
                entry.value['type'] ??
                entry.value['need'] ??
                'Unknown'; // Usar la clave correcta
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _victimCountFuture,
      builder: (context, snapshotCount) {
        if (snapshotCount.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshotCount.hasError) {
          return Center(child: Text('Error: ${snapshotCount.error}'));
        } else if (!snapshotCount.hasData || snapshotCount.data!.isEmpty) {
          return const Center(child: Text('No data available for line chart'));
        } else {
          final lineData = snapshotCount.data!;

          // Ordenar los datos por fecha
          final sortedLineData =
              lineData
                ..sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));

          // Crear los puntos para el gráfico de líneas
          final lineSpots =
              sortedLineData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['num'] ?? 0).toDouble(), // Manejar valores nulos
                );
              }).toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _victimNeedsFuture,
            builder: (context, snapshotNeeds) {
              if (snapshotNeeds.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshotNeeds.hasError) {
                return Center(child: Text('Error: ${snapshotNeeds.error}'));
              } else if (!snapshotNeeds.hasData ||
                  snapshotNeeds.data!.isEmpty) {
                return const Center(
                  child: Text('No data available for bar/pie charts'),
                );
              } else {
                final needsData = snapshotNeeds.data!;

                // Generar una lista de colores única
                final List<Color> uniqueColors = List<Color>.generate(
                  needsData.length,
                  (index) => Colors.primaries[index % Colors.primaries.length],
                );

                // Generar datos para gráficos de barras y pastel
                final barGroups = generateBarGroups(needsData);
                final pieSections = generatePieSections(
                  needsData,
                  uniqueColors,
                );

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
                        padding: const EdgeInsets.fromLTRB(
                          60.0,
                          16.0,
                          60.0,
                          100.0,
                        ),
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
                              minY:
                                  0, // Asegurar que el eje Y comience desde cero
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1, // Intervalo de 1 en el eje Y
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
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
                                      if (index >= 0 &&
                                          index < lineSpots.length) {
                                        return Text(
                                          sortedLineData[index]['date'] ?? '',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    interval:
                                        1, // Mostrar solo fechas de los puntos
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
                          padding: const EdgeInsets.fromLTRB(
                            60.0,
                            0,
                            30.0,
                            100.0,
                          ),
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
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
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
                                      if (index >= 0 &&
                                          index < needsData.length) {
                                        return Text(
                                          needsData[index]['type'] ?? '',
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
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    final index = group.x.toInt();
                                    if (index >= 0 &&
                                        index < needsData.length) {
                                      return BarTooltipItem(
                                        '${needsData[index]['type'] ?? ''}: ${rod.toY.toInt()}',
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
                      // Gráfico de pastel con leyenda
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  30.0,
                                  0,
                                  5.0,
                                  90.0,
                                ),
                                child: PieChart(
                                  PieChartData(
                                    sections: pieSections,
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: buildLegend(needsData, uniqueColors),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
