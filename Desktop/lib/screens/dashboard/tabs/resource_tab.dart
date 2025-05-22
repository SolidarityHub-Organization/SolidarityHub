import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/services/donation_services.dart';
import 'package:solidarityhub/widgets/common/custom_pie_chart.dart';

class RecursosTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const RecursosTab({Key? key, required this.fechaInicio, required this.fechaFin}) : super(key: key);

  @override
  State<RecursosTab> createState() => _RecursosTabState();
}

class _RecursosTabState extends State<RecursosTab> {
  late Future<double> _totalMoneyFuture;
  late Future<int> _totalResourcesFuture;
  late Future<int> _totalDonorsFuture;
  late Future<Map<String, int>> _donationsByTypeFuture;
  final ScrollController _pieChartScrollController = ScrollController();

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
    _loadData();
  }

  void _loadData() {
    _totalMoneyFuture = DonationServices.fetchTotalQuantityFiltered(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
      currency: 'EUR',
    );

    _totalResourcesFuture = DonationServices.fetchTotalPhysicalDonationsQuantity(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    ).catchError((error) {
      print('Error fetching physical donations: $error');
      return 0;
    });

    _totalDonorsFuture = DonationServices.fetchTotalDonors(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );

    _donationsByTypeFuture = DonationServices.fetchPhysicalDonationsTotalAmountByType(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
  }

  @override
  void didUpdateWidget(RecursosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _pieChartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minContentWidth = math.max(950.0, constraints.maxWidth);

        return TwoDimensionalScrollWidget(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minContentWidth, minHeight: constraints.maxHeight),
            child: IntrinsicWidth(
              child: Container(
                width: minContentWidth,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Resumen de Recursos',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: FutureBuilder<double>(
                              future: _totalMoneyFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Total recaudado', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  return _buildInfoCard('Total recaudado', 'Error al cargar');
                                } else {
                                  double value = snapshot.data ?? 0.0;
                                  return _buildInfoCard('Total recaudado', '€${value.toStringAsFixed(2)}');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: FutureBuilder<int>(
                              future: _totalResourcesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Recursos donados', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  return _buildInfoCard('Recursos donados', 'Error al cargar');
                                } else {
                                  return _buildInfoCard('Recursos donados', '${snapshot.data ?? 0}');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: FutureBuilder<int>(
                              future: _totalDonorsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Donantes activos', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  return _buildInfoCard('Donantes activos', 'Error al cargar');
                                } else {
                                  return _buildInfoCard('Donantes activos', '${snapshot.data ?? 0}');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 25.0),
                        child: Text(
                          'Distribución de recursos por tipo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      constraints: BoxConstraints(minWidth: math.max(700, constraints.maxWidth * 0.8)),
                      height: 400,
                      child: FutureBuilder<Map<String, int>>(
                        future: _donationsByTypeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error al cargar los datos: ${snapshot.error}',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No hay datos disponibles para este periodo'),
                            );
                          }

                          final data = snapshot.data!.entries
                              .map((entry) => {
                                    'type': entry.key,
                                    'count': entry.value,
                                  })
                              .toList();

                          return CustomPieChart(
                            data: data,
                            legendScrollController: _pieChartScrollController,
                            threshold: 5.0,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title, 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          Text(
            value, 
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
