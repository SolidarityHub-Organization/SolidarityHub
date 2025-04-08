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
    _victimNeedsFuture = _victimService.fetchVictimNeedsCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _victimNeedsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final data = snapshot.data!;
          final barGroups =
              data
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['item2'] as int).toDouble(),
                          color: const Color(
                            0xFFF44336,
                          ), // Color rojo para las barras
                          width: 30, // Barras más gruesas
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )
                  .toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Afectados y sus necesidades',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    60.0, // Margen izquierdo igual al derecho
                    0,
                    60.0, // Margen derecho
                    20.0, // Margen inferior
                  ),
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles:
                                false, // Ocultar números del eje izquierdo
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // Mostrar solo números enteros
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 == 0) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles:
                                false, // Ocultar números del eje superior
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize:
                                40, // Aumentar espacio para los nombres del eje inferior
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 12.0,
                                ), // Separar los nombres del gráfico
                                child: Text(
                                  data[value.toInt()]['item1'] as String,
                                  style: const TextStyle(
                                    color: Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ), // Ejes en rojo
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
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
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.red,

                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${data[group.x.toInt()]['item1']}: ${rod.toY.toInt()}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
