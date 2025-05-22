import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solidarityhub/screens/dashboard/tabs/task_tab.dart';
import 'tabs/general_tab.dart';
import 'tabs/victim_tab.dart';
import 'tabs/resource_tab.dart';
import 'tabs/volunteer_tab.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _refreshCurrentTab() {
    setState(() {});
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _fechaFin ?? DateTime.now(),
    );

    if (picked != null) {
      // Verificar que la fecha seleccionada no sea posterior a la fecha fin
      if (_fechaFin != null && picked.isAfter(_fechaFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La fecha de inicio no puede ser posterior a la fecha de fin'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _fechaInicio = picked;
        _refreshCurrentTab();
      });
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, seleccione primero una fecha de inicio'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2000), // La fecha inicial mínima debe ser la fecha de inicio
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Verificamos que la fecha de fin no sea anterior a la fecha de inicio
      if (picked.isBefore(_fechaInicio!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La fecha de fin no puede ser anterior a la fecha de inicio'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _fechaFin = picked;
        _refreshCurrentTab();
      });
    }
  }

  List<Widget> _buildDateFilters() {
    // Formatear fechas para mostrar
    String textoInicio = 'Seleccionar inicio';
    String textoFin = 'Seleccionar fin';

    if (_fechaInicio != null) {
      textoInicio = 'Inicio: ${DateFormat('dd-MM-yyyy').format(_fechaInicio!)}';
    }

    if (_fechaFin != null) {
      textoFin = 'Fin: ${DateFormat('dd-MM-yyyy').format(_fechaFin!)}';

      // Si las fechas son iguales, indicarlo
      if (_fechaInicio != null &&
          _fechaInicio!.year == _fechaFin!.year &&
          _fechaInicio!.month == _fechaFin!.month &&
          _fechaInicio!.day == _fechaFin!.day) {
        textoFin += ' (mismo día)';
      }
    }

    return [
      TextButton(
        onPressed: () => _selectFechaInicio(context),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(textoInicio, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: () => _selectFechaFin(context),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(textoFin, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    ];
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
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool hasEnoughSpace = constraints.maxWidth > 775;

                      if (hasEnoughSpace) {
                        // wide layout
                        return Column(
                          children: [
                            Row(
                              children: [
                                // tabs left
                                Expanded(
                                  child: Scrollbar(
                                    controller: _tabScrollController,
                                    thumbVisibility: true,
                                    thickness: 6.0,
                                    radius: const Radius.circular(10.0),
                                    scrollbarOrientation: ScrollbarOrientation.bottom,
                                    child: SingleChildScrollView(
                                      controller: _tabScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: TabBar(
                                        controller: _tabController,
                                        isScrollable: true,
                                        indicatorColor: Colors.white,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Colors.white70,
                                        dividerColor: Colors.transparent,
                                        tabs: const [
                                          Tab(text: 'General', icon: Icon(Icons.dashboard, size: 16)),
                                          Tab(text: 'Afectados', icon: Icon(Icons.people, size: 16)),
                                          Tab(text: 'Recursos', icon: Icon(Icons.inventory, size: 16)),
                                          Tab(text: 'Voluntarios', icon: Icon(Icons.volunteer_activism, size: 16)),
                                          Tab(text: 'Tareas', icon: Icon(Icons.task, size: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // filters on right
                                Row(mainAxisSize: MainAxisSize.min, children: _buildDateFilters()),
                              ],
                            ),
                            // indicator line
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white70,
                              margin: const EdgeInsets.only(top: 4.0),
                            ),
                          ],
                        );
                      } else {
                        // narrow layout
                        return Column(
                          children: [
                            Scrollbar(
                              controller: _tabScrollController,
                              thumbVisibility: true,
                              thickness: 6.0,
                              radius: const Radius.circular(10.0),
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              child: SingleChildScrollView(
                                controller: _tabScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // regular tabs
                                    TabBar(
                                      controller: _tabController,
                                      isScrollable: true,
                                      indicatorColor: Colors.white,
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.white70,
                                      dividerColor: Colors.transparent,
                                      tabs: const [
                                        Tab(text: 'General', icon: Icon(Icons.dashboard, size: 16)),
                                        Tab(text: 'Afectados', icon: Icon(Icons.people, size: 16)),
                                        Tab(text: 'Recursos', icon: Icon(Icons.inventory, size: 16)),
                                        Tab(text: 'Voluntarios', icon: Icon(Icons.volunteer_activism, size: 16)),
                                        Tab(text: 'Tareas', icon: Icon(Icons.task, size: 16)),
                                      ],
                                    ),
                                    // add spacer and date filters in the same scrollable area
                                    const SizedBox(width: 20),
                                    ...(_buildDateFilters().map(
                                      (widget) =>
                                          Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: widget),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            // indicator line
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white,
                              margin: const EdgeInsets.only(top: 4.0),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
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
                RecursosTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
                VolunteerTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
                TaskTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
