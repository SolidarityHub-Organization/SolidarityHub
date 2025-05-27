import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/widgets/common/custom_bar_chart.dart';
import 'package:solidarityhub/widgets/common/custom_pie_chart.dart';

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
  final ScrollController _barChartLegendController = ScrollController();
  final ScrollController _pieChartLegendController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = _adjustStartDate(widget.fechaInicio ?? now.subtract(const Duration(days: 365)));
    final end = _adjustEndDate(widget.fechaFin);
    _volunteerNeedsFuture = VolunteerServices.fetchFilteredVolunteerSkillsCount(start, end);
  }

  @override
  void didUpdateWidget(covariant VolunteerTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        final start = _adjustStartDate(widget.fechaInicio ?? DateTime.now().subtract(const Duration(days: 365)));
        final end = _adjustEndDate(widget.fechaFin);
        _volunteerNeedsFuture = VolunteerServices.fetchFilteredVolunteerSkillsCount(start, end);
      });
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _barChartLegendController.dispose();
    _pieChartLegendController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
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
                      return const Center(child: Text('No hay datos para mostrar.'));
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
                          CustomBarChart(
                            data: data,
                            barColor: Colors.red,
                            padding: const EdgeInsets.fromLTRB(40, 0, 50, 0),
                            title: 'Número de voluntarios por habilidad',
                            titleBottomMargin: 25.0,
                            threshold: 10.0,
                            legendScrollController: _barChartLegendController,
                          ),
                          const SizedBox(height: 15),
                          const Divider(height: 40, thickness: 2, indent: 40, endIndent: 40, color: Colors.grey),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 25.0),
                              child: Text(
                                'Proporción de voluntarios por habilidad',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            constraints: BoxConstraints(minWidth: math.max(700, constraints.maxWidth * 0.8)),
                            height: 400,
                            child: CustomPieChart(
                              data: data.map((item) => {'type': item['item1'], 'count': item['item2']}).toList(),
                              legendScrollController: _pieChartLegendController,
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
