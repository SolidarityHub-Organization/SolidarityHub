import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar intl para manejar fechas
import 'package:solidarityhub/LogicPresentation/dashboard/tables/taskTable.dart';
import 'tables/generalTable.dart';
import 'tables/victimTable.dart';
import 'tables/resourceTable.dart';
import 'tables/volunteerTable.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _refreshCurrentTab() {
    setState(() {});
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        _refreshCurrentTab();
      });
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
        _refreshCurrentTab();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: const [
                            Tab(text: 'General'),
                            Tab(text: 'Afectados'),
                            Tab(text: 'Recursos'),
                            Tab(text: 'Voluntarios'),
                            Tab(text: 'Tareas'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _selectFechaInicio(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white, // Fondo blanco
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  _fechaInicio != null
                                      ? 'Inicio: ${DateFormat('dd-MM-yyyy').format(_fechaInicio!)}'
                                      : 'Seleccionar inicio',
                                  style: const TextStyle(color: Colors.red), // Texto rojo
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _selectFechaFin(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white, // Fondo blanco
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  _fechaFin != null
                                      ? 'Fin: ${DateFormat('dd-MM-yyyy').format(_fechaFin!)}'
                                      : 'Seleccionar fin',
                                  style: const TextStyle(color: Colors.red), // Texto rojo
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GeneralTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
                VictimsTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
                const RecursosTab(),
                VolunteerTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
                TaskTable(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
