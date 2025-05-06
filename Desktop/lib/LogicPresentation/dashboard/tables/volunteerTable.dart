import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/LogicPresentation/common_widgets/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/LogicPresentation/common_widgets/custom_bar_chart.dart';
import 'package:solidarityhub/LogicPresentation/common_widgets/custom_pie_chart.dart';

class VolunteerTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const VolunteerTab({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  _VolunteerTabState createState() => _VolunteerTabState();
}

class _VolunteerTabState extends State<VolunteerTab> {
  late Future<List<Map<String, dynamic>>> _volunteerNeedsFuture;

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _legendScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = _adjustStartDate(widget.fechaInicio ?? now.subtract(const Duration(days: 365)));
    final end = _adjustEndDate(widget.fechaFin);
    _volunteerNeedsFuture = VolunteerService.fetchFilteredVolunteerSkillsCount(start, end);
  }

  @override
  void didUpdateWidget(covariant VolunteerTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        final start = _adjustStartDate(widget.fechaInicio ?? DateTime.now().subtract(const Duration(days: 365)));
        final end = _adjustEndDate(widget.fechaFin);
        _volunteerNeedsFuture = VolunteerService.fetchFilteredVolunteerSkillsCount(start, end);
      });
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _legendScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double _calculateMaxTitleWidth(List<Map<String, dynamic>> data) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );

    double maxWidth = 0;
    for (var item in data) {
      textPainter.text = TextSpan(
        text: item['item1'] as String,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      maxWidth = math.max(maxWidth, textPainter.width);
    }
    return maxWidth * 1; // add a % of padding
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
            child: IntrinsicHeight(
              child: Container(
                width: math.max(800, constraints.maxWidth),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
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

                      return Column(
                        children: [
                          const Text(
                            'Voluntarios y sus habilidades',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // bar chart
                          CustomBarChart(
                            data: data,
                            barColor: const Color(0xFFF44336),
                            //padding: const EdgeInsets.fromLTRB(40, 0, 20, 40),  // you can overrife the default padding
                          ),
                          const SizedBox(height: 30),
                          // pie chart
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            constraints: BoxConstraints(minWidth: math.max(700, constraints.maxWidth * 0.8)),
                            height: 400,
                            child: CustomPieChart(
                              data: data.map((item) => {'type': item['item1'], 'count': item['item2']}).toList(),
                              legendScrollController: _legendScrollController,
                              padding: const EdgeInsets.fromLTRB(30, 0, 20, 50),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildLegendItem(MapEntry<String, int> entry, double percentage, bool isInOther, Map<String, int> groupedData) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isInOther ? Colors.grey[700] : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    isInOther
                        ? Colors.grey
                        : Colors.primaries[groupedData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isInOther ? Colors.grey[700] : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
