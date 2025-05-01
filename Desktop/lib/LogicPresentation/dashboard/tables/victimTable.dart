import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/victimServices.dart';

class VictimsTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const VictimsTab({
    Key? key,
    required this.fechaFin,
    required this.fechaInicio,
  }) : super(key: key);

  @override
  _VictimsTabState createState() => _VictimsTabState();
}

class _VictimsTabState extends State<VictimsTab> {
  final VictimService _victimService = VictimService('http://localhost:5170');

  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    // Ajustar la fecha fin para incluir todo el día (23:59:59.999)
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    // Ajustar la fecha inicio para comenzar al principio del día (00:00:00.000)
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  late final Future<List<Map<String, dynamic>>> _victimCountFuture =
      _victimService.fetchVictimCountByDate().catchError((error) {
        print('Error al obtener datos de víctimas por fecha: $error');
        return <Map<String, dynamic>>[];
      });

  late Future<List<Map<String, dynamic>>> _victimNeedsFuture = _victimService
      .fetchFilteredVictimCounts(
        _adjustStartDate(widget.fechaInicio),
        _adjustEndDate(widget.fechaFin),
      )
      .catchError((error) {
        print('Error al obtener datos filtrados de víctimas: $error');
        return <Map<String, dynamic>>[];
      });

  @override
  void didUpdateWidget(covariant VictimsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio ||
        oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _victimNeedsFuture = _victimService
            .fetchFilteredVictimCounts(
              _adjustStartDate(widget.fechaInicio),
              _adjustEndDate(widget.fechaFin),
            )
            .catchError((error) {
              print('Error al actualizar datos filtrados de víctimas: $error');
              return <Map<String, dynamic>>[];
            });
      });
    }
  }

  List<BarChartGroupData> generateBarGroups(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: (entry.value['count'] ?? 0).toDouble(),
            color: Colors.red,
            width: 30,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> generatePieSections(
    List<Map<String, dynamic>> data,
    List<Color> uniqueColors,
  ) {
    final total = data.fold<int>(
      0,
      (sum, entry) => sum + ((entry['count'] ?? 0) as int),
    );

    return data.asMap().entries.map((entry) {
      final value = (entry.value['count'] ?? 0).toDouble();
      final percentage =
          total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
      return PieChartSectionData(
        value: value,
        title: '$percentage%',
        color: uniqueColors[entry.key],
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
            final color = uniqueColors[entry.key];
            final label =
                entry.value['type'] ?? entry.value['need'] ?? 'Unknown';
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

          final sortedLineData =
              lineData
                ..sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));

          final startDate = _adjustStartDate(widget.fechaInicio);
          final endDate = _adjustEndDate(widget.fechaFin);

          final filteredLineData =
              sortedLineData.where((entry) {
                final rawDate = entry['date'] ?? '';
                final parts = rawDate.split('-'); // Dividir la fecha en partes
                DateTime? entryDate;

                if (parts.length == 3) {
                  // Reorganizar las partes al formato yyyy-MM-dd
                  final formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
                  entryDate = DateTime.tryParse(formattedDate);
                }

                if (entryDate == null) return false;
                // Ajustar la comparación para incluir el día completo
                final entryEndOfDay = DateTime(
                  entryDate.year,
                  entryDate.month,
                  entryDate.day,
                  23,
                  59,
                  59,
                );
                return (entryDate.isAfter(startDate) ||
                        entryDate.isAtSameMomentAs(startDate)) &&
                    (entryEndOfDay.isBefore(endDate) ||
                        entryEndOfDay.isAtSameMomentAs(endDate));
              }).toList();

          final lineSpots =
              filteredLineData.asMap().entries.map((entry) {
                final index = entry.key.toDouble();
                final value = (entry.value['num'] ?? 0).toDouble();
                return FlSpot(
                  index,
                  value < 0 ? 0 : value,
                ); // Asegurar que el valor mínimo sea 0
              }).toList();

          // Asegurar que los puntos consecutivos con el mismo valor se mantengan constantes
          for (int i = 1; i < lineSpots.length; i++) {
            if (lineSpots[i].y == 0 && lineSpots[i - 1].y == 0) {
              lineSpots[i] = FlSpot(
                lineSpots[i].x,
                0,
              ); // Mantener constante en 0
            }
          }

          // Usar los datos filtrados para las etiquetas del eje X, no los originales
          final xLabels =
              filteredLineData.map((entry) {
                return entry['date'] ?? '';
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

                final List<Color> uniqueColors = List<Color>.generate(
                  needsData.length,
                  (index) => Colors.primaries[index % Colors.primaries.length],
                );

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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          60.0,
                          16.0,
                          60.0,
                          0.0, // Reducido el padding inferior
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Número de afectados por día',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          60.0,
                          8.0, // Reducido para ajustar el espacio con el nuevo título
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
                                  preventCurveOverShooting:
                                      true, // Previene que la curva sobrepase los puntos
                                  preventCurveOvershootingThreshold:
                                      1.0, // Umbral para el control de la curva
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red.withOpacity(0.3),
                                    cutOffY: 0,
                                    applyCutOffY: true,
                                    spotsLine: BarAreaSpotsLine(
                                      show:
                                          true, // Mostrar líneas verticales desde los puntos al eje X
                                      flLineStyle: FlLine(
                                        color: Colors.red.withOpacity(0.2),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      // Asegurar que los puntos no aparezcan por debajo del eje X
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.red,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  isStrokeCapRound: true,
                                ),
                              ],
                              minX: 0,
                              maxX:
                                  lineSpots.isNotEmpty
                                      ? (lineSpots.length - 1).toDouble()
                                      : 0,
                              minY: 0, // Forzar que el mínimo sea siempre 0
                              maxY:
                                  lineSpots.isNotEmpty
                                      ? (lineSpots
                                              .map((spot) => spot.y)
                                              .reduce((a, b) => a > b ? a : b) +
                                          1)
                                      : 1,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < xLabels.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ), // Separación por arriba
                                          child: Text(
                                            xLabels[index],
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    interval: 1,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.5),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.5),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: true),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.red,
                                  tooltipPadding: const EdgeInsets.all(8.0),
                                  tooltipMargin: 8,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      return LineTooltipItem(
                                        '${spot.y.toInt()}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          60.0,
                          30.0, // Añado espacio superior para separar del gráfico anterior
                          60.0,
                          10.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Cantidad de cada tipo de necesidad',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 500,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            60.0,
                            8.0, // Espacio reducido después del título
                            30.0,
                            100.0,
                          ),
                          child: BarChart(
                            BarChartData(
                              barGroups: barGroups,
                              maxY:
                                  barGroups.isNotEmpty
                                      ? (barGroups
                                              .map(
                                                (group) =>
                                                    group.barRods.first.toY,
                                              )
                                              .reduce((a, b) => a > b ? a : b) +
                                          1)
                                      : 1,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
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
                                drawHorizontalLine: false,
                                drawVerticalLine: true,
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.5),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Colors.red,
                                  tooltipPadding: const EdgeInsets.all(8.0),
                                  tooltipMargin: 8,
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      '${rod.toY.toInt()}',
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
