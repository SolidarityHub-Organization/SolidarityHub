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

          final totalValue = data.fold<int>(
            0,
            (sum, entry) => sum + (entry['item2'] as int),
          );

          final pieSections =
              data
                  .map(
                    (entry) => PieChartSectionData(
                      value: (entry['item2'] as int).toDouble(),
                      title:
                          entry['item1'], // Mostrar necesidad dentro del trozo
                      color:
                          Colors.primaries[data.indexOf(entry) %
                              Colors.primaries.length], // Colores dinámicos
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      badgeWidget: Text(
                        '${((entry['item2'] as int) / totalValue * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      badgePositionPercentageOffset:
                          1.3, // Posición más estilizada
                    ),
                  )
                  .toList();

          return Column(
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
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60.0, 0, 30.0, 20.0),
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
                                        ), // Acercar al gráfico
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
                                sideTitles: SideTitles(
                                  showTitles:
                                      false, // Ocultar números en el eje derecho
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        data[value.toInt()]['item1'] as String,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
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
                              show:
                                  false, // Eliminar las líneas que rodean el gráfico
                            ),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.red,
                                getTooltipItem: (
                                  group,
                                  groupIndex,
                                  rod,
                                  rodIndex,
                                ) {
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 0, 60.0, 20.0),
                        child: PieChart(
                          PieChartData(
                            sections: pieSections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 4, // Más espacio entre secciones
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
