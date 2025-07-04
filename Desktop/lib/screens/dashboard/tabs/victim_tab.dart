import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:solidarityhub/services/victim_services.dart';
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/widgets/common/custom_line_chart.dart';
import 'package:solidarityhub/widgets/common/custom_bar_chart.dart';
import 'package:solidarityhub/widgets/common/custom_pie_chart.dart';

class VictimsTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const VictimsTab({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  _VictimsTabState createState() => _VictimsTabState();
}

class _VictimsTabState extends State<VictimsTab> {
  final ScrollController _legendScrollController = ScrollController();

  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  late final Future<List<Map<String, dynamic>>> _victimCountFuture = VictimServices.fetchVictimCountByDate().catchError(
    (error) {
      print('Error al obtener datos de víctimas por fecha: $error');
      return <Map<String, dynamic>>[];
    },
  );

  late Future<List<Map<String, dynamic>>> _victimNeedsFuture = VictimServices.fetchFilteredVictimCounts(
    _adjustStartDate(widget.fechaInicio),
    _adjustEndDate(widget.fechaFin),
  ).catchError((error) {
    print('Error al obtener datos filtrados de víctimas: $error');
    return <Map<String, dynamic>>[];
  });

  @override
  void didUpdateWidget(covariant VictimsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _victimNeedsFuture = VictimServices.fetchFilteredVictimCounts(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        ).catchError((error) {
          print('Error al actualizar datos filtrados de víctimas: $error');
          return <Map<String, dynamic>>[];
        });
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        // Convert from DD-MM-YYYY to YYYY-MM-DD for proper parsing
        return DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
      return null;
    } catch (e) {
      print('Error parsing date: $dateStr, error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TwoDimensionalScrollWidget(
          child: Container(
            constraints: BoxConstraints(
              minWidth: math.max(800, constraints.maxWidth),
              minHeight: constraints.maxHeight,
            ),
            width: math.max(800, constraints.maxWidth),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _victimCountFuture,
              builder: (context, snapshotCount) {
                if (snapshotCount.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshotCount.hasError) {
                  return Center(child: Text('Error: ${snapshotCount.error}'));
                } else if (!snapshotCount.hasData || snapshotCount.data!.isEmpty) {
                  return const Center(child: Text('No hay datos para mostrar.'));
                } else {
                  final lineData = snapshotCount.data!;
                  final sortedLineData = List<Map<String, dynamic>>.from(lineData)
                    ..sort((a, b) {
                      DateTime? dateA = _parseDate(a['date'] ?? '');
                      DateTime? dateB = _parseDate(b['date'] ?? '');

                      if (dateA == null && dateB == null) return 0;
                      if (dateA == null) return -1;
                      if (dateB == null) return 1;

                      return dateA.compareTo(dateB);
                    });

                  final startDate = _adjustStartDate(widget.fechaInicio);
                  final endDate = _adjustEndDate(widget.fechaFin);

                  final filteredLineData =
                      sortedLineData.where((entry) {
                        final rawDate = entry['date'] ?? '';
                        final parts = rawDate.split('-');
                        DateTime? entryDate;

                        if (parts.length == 3) {
                          final formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
                          entryDate = DateTime.tryParse(formattedDate);
                        }

                        if (entryDate == null) return false;
                        final entryEndOfDay = DateTime(entryDate.year, entryDate.month, entryDate.day, 23, 59, 59);
                        return (entryDate.isAfter(startDate) || entryDate.isAtSameMomentAs(startDate)) &&
                            (entryEndOfDay.isBefore(endDate) || entryEndOfDay.isAtSameMomentAs(endDate));
                      }).toList();

                  final lineSpots =
                      filteredLineData.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final value = (entry.value['num'] ?? 0).toDouble();
                        return FlSpot(index, value < 0 ? 0 : value);
                      }).toList();

                  final xLabels = filteredLineData.map((entry) => (entry['date'] ?? '').toString()).toList();

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _victimNeedsFuture,
                    builder: (context, snapshotNeeds) {
                      if (snapshotNeeds.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshotNeeds.hasError) {
                        return Center(child: Text('Error: ${snapshotNeeds.error}'));
                      } else if (!snapshotNeeds.hasData || snapshotNeeds.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }

                      final needsData = snapshotNeeds.data!;

                      final transformedNeedsData =
                          needsData.map((item) {
                            // make sure keys exist and values are properly typed
                            return {'item1': (item['type'] ?? 'Unknown').toString(), 'item2': item['count'] ?? 0};
                          }).toList();

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
                          CustomLineChart(
                            spots: lineSpots,
                            xLabels: xLabels,
                            title: 'Número de afectados por día',
                            titleBottomMargin: 25.0,
                            padding: const EdgeInsets.fromLTRB(60, 0, 70, 50),
                          ),
                          const Divider(height: 40, thickness: 2, indent: 40, endIndent: 40, color: Colors.grey),
                          CustomBarChart(
                            data: transformedNeedsData,
                            barColor: Colors.red,
                            title: 'Número de afectados por tipos de necesidad',
                            titleBottomMargin: 25.0,
                            padding: const EdgeInsets.fromLTRB(60, 0, 70, 50),
                            threshold: 10.0,
                            legendScrollController: _legendScrollController,
                          ),
                          const Divider(height: 40, thickness: 2, indent: 40, endIndent: 40, color: Colors.grey),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 25.0),
                              child: Text(
                                'Proporción de afectados por tipos de necesidad',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            constraints: BoxConstraints(minWidth: math.max(700, constraints.maxWidth * 0.8)),
                            height: 400,
                            child: CustomPieChart(
                              data:
                                  needsData
                                      .map(
                                        (item) => {
                                          'type': (item['type'] ?? 'Unknown').toString(),
                                          'count': item['count'] ?? 0,
                                        },
                                      )
                                      .toList(),
                              legendScrollController: _legendScrollController,
                              padding: const EdgeInsets.fromLTRB(30, 0, 20, 50),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _legendScrollController.dispose();
    super.dispose();
  }
}
