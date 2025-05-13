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
    if (_fechaInicio == null) {
      // Mostrar aviso de que debe seleccionar primero la fecha de inicio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, seleccione primero una fecha de inicio'),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    // actualizar el estado si se seleccionó una fecha
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
        _refreshCurrentTab();
      });
    }
  }

  List<Widget> _buildDateFilters() {
    return [
      TextButton(
        onPressed: () => _selectFechaInicio(context),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _fechaInicio != null ? 'Inicio: ${DateFormat('dd-MM-yyyy').format(_fechaInicio!)}' : 'Seleccionar inicio',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: () => _selectFechaFin(context),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _fechaFin != null ? 'Fin: ${DateFormat('dd-MM-yyyy').format(_fechaFin!)}' : 'Seleccionar fin',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'), //should we remove the title and leave only the arrow at the height of the tabs?
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
            width: double.infinity, // red container full width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // transition threshold
                      final bool hasEnoughSpace =
                          constraints.maxWidth > 775; // could change so it auto calculates the needed space

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
                                    radius: Radius.circular(10.0),
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
                              margin: const EdgeInsets.only(top: 0),
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
                              radius: Radius.circular(10.0),
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
                              margin: const EdgeInsets.only(top: 0),
                            ),
                          ],
                        );
                      }
                    },
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
                TaskTab(fechaInicio: _fechaInicio, fechaFin: _fechaFin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
