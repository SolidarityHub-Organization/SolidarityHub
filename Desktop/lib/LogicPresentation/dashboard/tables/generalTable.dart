import 'package:flutter/material.dart';
import 'package:solidarityhub/services/generalServices.dart';
import 'dart:math' as math;
import 'package:solidarityhub/LogicPresentation/common_widgets/two_dimensional_scroll_widget.dart';

class GeneralTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const GeneralTab({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GeneralTabState(); // Implementación corregida
  }
}

class _GeneralTabState extends State<GeneralTab> {
  final GeneralService _generalService = GeneralService('http://localhost:5170');

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

  late Future<int> _victimCountFuture;
  late Future<int> _volunteerCountFuture;
  late Future<double> _donationTotalFuture;
  late Future<int> _completedTasksCountFuture;

  @override
  void initState() {
    super.initState();
    _victimCountFuture = _generalService.fetchVictimCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _volunteerCountFuture = _generalService.fetchVolunteerCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _donationTotalFuture = _generalService
        .fetchTotalQuantityFiltered(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
          currency: 'EUR',
        )
        .then((value) => value.toDouble());
    _completedTasksCountFuture = _generalService.fetchTaskCountByStateFiltered(
      'Completed',
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
  }

  @override
  void didUpdateWidget(covariant GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _victimCountFuture = _generalService.fetchVictimCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _volunteerCountFuture = _generalService.fetchVolunteerCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _donationTotalFuture = _generalService
            .fetchTotalQuantityFiltered(
              _adjustStartDate(widget.fechaInicio),
              _adjustEndDate(widget.fechaFin),
              currency: 'EUR',
            )
            .then((value) => value.toDouble());
        _completedTasksCountFuture = _generalService.fetchTaskCountByStateFiltered(
          'Completed',
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minContentWidth = math.max(1100.0, constraints.maxWidth);

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
                      'Resumen General',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FutureBuilder<int>(
                              future: _victimCountFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Personas Afectadas', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  return _buildInfoCard(
                                    'Personas Afectadas',
                                    'Error: ${snapshot.error.toString().substring(0, math.min(30, snapshot.error.toString().length))}...',
                                  );
                                } else if (!snapshot.hasData) {
                                  return _buildInfoCard('Personas Afectadas', 'Sin datos');
                                } else {
                                  return _buildInfoCard('Personas Afectadas', snapshot.data.toString());
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: FutureBuilder<int>(
                              future: _volunteerCountFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Voluntarios Totales', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  return _buildInfoCard('Voluntarios Totales', 'Error');
                                } else {
                                  return _buildInfoCard('Voluntarios Totales', snapshot.data.toString());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FutureBuilder<double>(
                              future: _donationTotalFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Donaciones Recibidas', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  print("Error en FutureBuilder de donaciones: ${snapshot.error}");
                                  return _buildInfoCard('Donaciones Recibidas', 'Error al cargar');
                                } else {
                                  // Manejar el caso donde snapshot.data sea null de forma segura
                                  double value = snapshot.data ?? 0.0;
                                  // Ya es double, no necesita conversión
                                  return _buildInfoCard('Donaciones Recibidas', '€${value.toStringAsFixed(2)}');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: FutureBuilder<int>(
                              future: _completedTasksCountFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoCard('Tareas Completadas', 'Cargando...');
                                } else if (snapshot.hasError) {
                                  print("Error en FutureBuilder de tareas: ${snapshot.error}");
                                  return _buildInfoCard('Tareas Completadas', 'Error al cargar');
                                } else {
                                  // Manejar el caso donde snapshot.data sea null de forma segura
                                  int value = snapshot.data ?? 0;
                                  return _buildInfoCard('Tareas Completadas', value.toString());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 12.0),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}
