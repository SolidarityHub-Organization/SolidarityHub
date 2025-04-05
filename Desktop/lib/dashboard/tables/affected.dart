import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common_widgets.dart';

class AfectadosTab extends StatelessWidget {
  final String selectedPeriod;

  const AfectadosTab({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartSection(
            title: 'Afectados por Tipo de Necesidad',
            chart: buildNecesidadesBarChart(),
          ),
          const SizedBox(height: 16),
          ChartSection(
            title: 'Distribución de Necesidades',
            chart: buildNecesidadesPieChart(),
          ),
          const SizedBox(height: 16),
          ChartSection(
            title: 'Evolución de Necesidades por Día',
            chart: buildNecesidadesLineChart(),
            height: 300,
          ),
          const SizedBox(height: 16),
          _buildNecesidadesComparativaCard(context),
        ],
      ),
    );
  }

  Widget _buildNecesidadesComparativaCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativa de Necesidades Cubiertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProgressRow(
              context: context,
              title: 'Evacuación',
              total: 320,
              current: 280,
              porcentaje: 0.875,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Alimentos y Agua',
              total: 450,
              current: 380,
              porcentaje: 0.844,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Asistencia Médica',
              total: 280,
              current: 180,
              porcentaje: 0.643,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Refugio',
              total: 380,
              current: 350,
              porcentaje: 0.921,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Ropa y Abrigo',
              total: 220,
              current: 150,
              porcentaje: 0.682,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Rescate Urgente',
              total: 180,
              current: 160,
              porcentaje: 0.889,
            ),
          ],
        ),
      ),
    );
  }

  // Gráficos para la pestaña de Afectados
  Widget buildNecesidadesBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 500,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String category;
              switch (groupIndex) {
                case 0:
                  category = 'Evacuación';
                  break;
                case 1:
                  category = 'Alimentos';
                  break;
                case 2:
                  category = 'Médica';
                  break;
                case 3:
                  category = 'Refugio';
                  break;
                case 4:
                  category = 'Ropa';
                  break;
                case 5:
                  category = 'Rescate';
                  break;
                default:
                  category = '';
              }
              return BarTooltipItem(
                '$category\n${rod.toY.round()} personas',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Evacuación';
                    break;
                  case 1:
                    text = 'Alimentos';
                    break;
                  case 2:
                    text = 'Médica';
                    break;
                  case 3:
                    text = 'Refugio';
                    break;
                  case 4:
                    text = 'Ropa';
                    break;
                  case 5:
                    text = 'Rescate';
                    break;
                  default:
                    text = '';
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 100,
          drawVerticalLine: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 320,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 450,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 280,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 380,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 220,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 180,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNecesidadesPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
        sections: [
          PieChartSectionData(
            value: 25,
            title: '25%',
            color: Colors.red.shade800,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 35,
            title: '35%',
            color: Colors.red.shade600,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 20,
            title: '20%',
            color: Colors.red.shade400,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 10,
            title: '10%',
            color: Colors.red.shade300,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 5,
            title: '5%',
            color: Colors.red.shade200,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          PieChartSectionData(
            value: 5,
            title: '5%',
            color: Colors.red.shade100,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNecesidadesLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Día 1';
                    break;
                  case 1:
                    text = 'Día 2';
                    break;
                  case 2:
                    text = 'Día 3';
                    break;
                  case 3:
                    text = 'Día 4';
                    break;
                  case 4:
                    text = 'Día 5';
                    break;
                  case 5:
                    text = 'Día 6';
                    break;
                  case 6:
                    text = 'Día 7';
                    break;
                  default:
                    text = '';
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 200,
        lineBarsData: [
          // Línea para Evacuación
          LineChartBarData(
            spots: const [
              FlSpot(0, 30),
              FlSpot(1, 70),
              FlSpot(2, 120),
              FlSpot(3, 100),
              FlSpot(4, 80),
              FlSpot(5, 60),
              FlSpot(6, 40),
            ],
            isCurved: true,
            color: Colors.red.shade800,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.shade800.withOpacity(0.1),
            ),
          ),
          // Línea para Alimentos
          LineChartBarData(
            spots: const [
              FlSpot(0, 40),
              FlSpot(1, 80),
              FlSpot(2, 130),
              FlSpot(3, 150),
              FlSpot(4, 140),
              FlSpot(5, 120),
              FlSpot(6, 100),
            ],
            isCurved: true,
            color: Colors.red.shade600,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.shade600.withOpacity(0.1),
            ),
          ),
          // Línea para Médica
          LineChartBarData(
            spots: const [
              FlSpot(0, 20),
              FlSpot(1, 50),
              FlSpot(2, 90),
              FlSpot(3, 120),
              FlSpot(4, 100),
              FlSpot(5, 80),
              FlSpot(6, 70),
            ],
            isCurved: true,
            color: Colors.red.shade400,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.shade400.withOpacity(0.1),
            ),
          ),
          // Línea para Refugio
          LineChartBarData(
            spots: const [
              FlSpot(0, 50),
              FlSpot(1, 90),
              FlSpot(2, 120),
              FlSpot(3, 140),
              FlSpot(4, 130),
              FlSpot(5, 110),
              FlSpot(6, 90),
            ],
            isCurved: true,
            color: Colors.red.shade300,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.shade300.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                String type = '';
                Color color = Colors.red;

                switch (barSpot.barIndex) {
                  case 0:
                    type = 'Evacuación';
                    color = Colors.red.shade800;
                    break;
                  case 1:
                    type = 'Alimentos';
                    color = Colors.red.shade600;
                    break;
                  case 2:
                    type = 'Médica';
                    color = Colors.red.shade400;
                    break;
                  case 3:
                    type = 'Refugio';
                    color = Colors.red.shade300;
                    break;
                }

                return LineTooltipItem(
                  '$type: ${flSpot.y.toInt()}',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
