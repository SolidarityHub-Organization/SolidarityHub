import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common_widgets.dart';

class VolunteersTab extends StatelessWidget {
  final String selectedPeriod;

  const VolunteersTab({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartSection(
            title: 'Voluntarios por Habilidad',
            chart: buildHabilidadesBarChart(),
          ),
          const SizedBox(height: 16),
          ChartSection(
            title: 'Demanda vs Disponibilidad de Habilidades',
            chart: buildHabilidadesComparativaChart(),
            height: 300,
          ),
          const SizedBox(height: 16),
          ChartSection(
            title: 'Distribución de Voluntarios por Habilidad',
            chart: buildHabilidadesPieChart(),
          ),
          const SizedBox(height: 16),
          _buildVoluntariosDisponibilidadCard(context),
        ],
      ),
    );
  }

  Widget _buildVoluntariosDisponibilidadCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cobertura de Necesidades por Habilidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProgressRow(
              context: context,
              title: 'Médico/Enfermero',
              total: 80,
              current: 45,
              porcentaje: 0.563,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Rescate',
              total: 90,
              current: 60,
              porcentaje: 0.667,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Logística',
              total: 70,
              current: 80,
              porcentaje: 1.143,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Apoyo General',
              total: 100,
              current: 110,
              porcentaje: 1.100,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Transporte',
              total: 50,
              current: 35,
              porcentaje: 0.700,
            ),
            const SizedBox(height: 12),
            ProgressRow(
              context: context,
              title: 'Cocina',
              total: 30,
              current: 25,
              porcentaje: 0.833,
            ),
          ],
        ),
      ),
    );
  }

  // Gráficos para la pestaña de Voluntarios
  Widget buildHabilidadesBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 120,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String category;
              switch (groupIndex) {
                case 0:
                  category = 'Médico';
                  break;
                case 1:
                  category = 'Rescate';
                  break;
                case 2:
                  category = 'Logística';
                  break;
                case 3:
                  category = 'Apoyo';
                  break;
                case 4:
                  category = 'Transporte';
                  break;
                case 5:
                  category = 'Cocina';
                  break;
                default:
                  category = '';
              }
              return BarTooltipItem(
                '$category\n${rod.toY.round()} voluntarios',
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
                    text = 'Médico';
                    break;
                  case 1:
                    text = 'Rescate';
                    break;
                  case 2:
                    text = 'Logística';
                    break;
                  case 3:
                    text = 'Apoyo';
                    break;
                  case 4:
                    text = 'Transporte';
                    break;
                  case 5:
                    text = 'Cocina';
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
          horizontalInterval: 20,
          drawVerticalLine: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 45,
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
                toY: 60,
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
                toY: 80,
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
                toY: 110,
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
                toY: 35,
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
                toY: 25,
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

  Widget buildHabilidadesComparativaChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 120,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String category;
              switch (groupIndex) {
                case 0:
                  category = 'Médico';
                  break;
                case 1:
                  category = 'Rescate';
                  break;
                case 2:
                  category = 'Logística';
                  break;
                case 3:
                  category = 'Apoyo';
                  break;
                case 4:
                  category = 'Transporte';
                  break;
                case 5:
                  category = 'Cocina';
                  break;
                default:
                  category = '';
              }
              return BarTooltipItem(
                '$category\n${rod.rodStackItems[0].fromY.toInt()}-${rod.rodStackItems[1].toY.toInt()} ${rodIndex == 0 ? 'Disponibles' : 'Necesarios'}',
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
                    text = 'Médico';
                    break;
                  case 1:
                    text = 'Rescate';
                    break;
                  case 2:
                    text = 'Logística';
                    break;
                  case 3:
                    text = 'Apoyo';
                    break;
                  case 4:
                    text = 'Transporte';
                    break;
                  case 5:
                    text = 'Cocina';
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
          horizontalInterval: 20,
          drawVerticalLine: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 45,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 80,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 60,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 90,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 80,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 70,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 110,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 100,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 35,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 50,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 25,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: 30,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            groupVertically: true,
          ),
        ],
      ),
    );
  }

  Widget buildHabilidadesPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
        sections: [
          PieChartSectionData(
            value: 45,
            title: '13%',
            color: Colors.blue.shade800,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 60,
            title: '17%',
            color: Colors.blue.shade600,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 80,
            title: '23%',
            color: Colors.blue.shade400,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 110,
            title: '31%',
            color: Colors.blue.shade300,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 35,
            title: '10%',
            color: Colors.blue.shade200,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          PieChartSectionData(
            value: 25,
            title: '7%',
            color: Colors.blue.shade100,
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
}
