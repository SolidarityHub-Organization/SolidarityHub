import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/volunteerServices.dart';

class VolunteerTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const VolunteerTab({
    Key? key,
    required this.fechaFin,
    required this.fechaInicio,
  }) : super(key: key);

  @override
  _VolunteerTabState createState() => _VolunteerTabState();
}

class _VolunteerTabState extends State<VolunteerTab> {
  late Future<List<Map<String, dynamic>>> _volunteerNeedsFuture;
  final VolunteerService _volunteerService = VolunteerService(
    'http://localhost:5170',
  );

  @override
  void initState() {
    super.initState();
    _volunteerNeedsFuture = _volunteerService.fetchVolunteerSkillsCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _volunteerNeedsFuture,
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
                          color: const Color(0xFFF44336),
                          width: 30,
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
                      title: entry['item1'],
                      color:
                          Colors.primaries[data.indexOf(entry) %
                              Colors.primaries.length],
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
                      badgePositionPercentageOffset: 1.3,
                    ),
                  )
                  .toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Voluntarios y sus habilidades',
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
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
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
                            borderData: FlBorderData(show: false),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: const Color(0xFFF44336),
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
                            sectionsSpace: 4,
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
