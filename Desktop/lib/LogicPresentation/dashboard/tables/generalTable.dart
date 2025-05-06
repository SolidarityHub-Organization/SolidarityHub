import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:solidarityhub/LogicPresentation/common_widgets/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/services/dashboard_services.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/services/victim_services.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/services/donation_services.dart';

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
  late Future<List<dynamic>> _recentActivityFuture;

  @override
  void initState() {
    super.initState();
    _victimCountFuture = VictimService.fetchVictimCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _volunteerCountFuture = VolunteerService.fetchVolunteerCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _donationTotalFuture = DonationService.fetchTotalQuantityFiltered(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
      currency: 'EUR',
    ).then((value) => value.toDouble());
    _completedTasksCountFuture = TaskService.fetchTaskCountByStateFiltered(
      'Completed',
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _recentActivityFuture = DashboardServices.fetchRecentActivity(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
  }

  @override
  void didUpdateWidget(covariant GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _victimCountFuture = VictimService.fetchVictimCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _volunteerCountFuture = VolunteerService.fetchVolunteerCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _donationTotalFuture = DonationService.fetchTotalQuantityFiltered(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
          currency: 'EUR',
        ).then((value) => value.toDouble());
        _completedTasksCountFuture = TaskService.fetchTaskCountByStateFiltered(
          'Completed',
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _recentActivityFuture = DashboardServices.fetchRecentActivity(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Historial de Registros Recientes',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          _buildRecentActivityTable(),
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
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 12.0),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _recentActivityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error al cargar los datos: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(20.0), child: Text('No hay actividad reciente que mostrar')),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(12.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(item['type']),
                      child: Icon(_getTypeIcon(item['type']), color: Colors.white, size: 20),
                    ),
                    title: Text(
                      _buildRegistrationMessage(item),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item['date'] != null ? _formatDate(item['date']) : 'Fecha desconocida',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  String _buildRegistrationMessage(dynamic item) {
    String name = item['name'] ?? 'Persona';
    String type = item['type']?.toString().toLowerCase() ?? '';

    if (type.contains('victim') || type.contains('víctima')) {
      return '$name se ha registrado como afectado';
    } else if (type.contains('volunteer') || type.contains('voluntario')) {
      return '$name se ha registrado como voluntario';
    } else if (type.contains('donation') || type.contains('donación')) {
      return '$name ha realizado una donación';
    } else {
      return '$name se ha registrado';
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'victim':
      case 'víctima':
        return Icons.person_add_alt_1;
      case 'volunteer':
      case 'voluntario':
        return Icons.volunteer_activism;
      case 'donation':
      case 'donación':
        return Icons.card_giftcard;
      default:
        return Icons.person;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'victim':
      case 'víctima':
        return const Color.fromARGB(255, 255, 164, 163); // Rojo más intenso para afectados
      case 'volunteer':
      case 'voluntario':
        return const Color(0xFFC62828); // Rojo más oscuro para voluntarios
      case 'donation':
      case 'donación':
        return const Color(0xFF4CAF50); // Verde para donaciones
      default:
        return Colors.grey;
    }
  }
}
