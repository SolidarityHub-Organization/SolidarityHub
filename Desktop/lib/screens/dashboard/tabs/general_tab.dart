import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
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
    return _GeneralTabState();
  }
}

class _GeneralTabState extends State<GeneralTab> {
  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  late Future<int> _victimCountFuture;
  late Future<int> _volunteerCountFuture;
  late Future<double> _donationTotalFuture;
  late Future<int> _completedTasksCountFuture;
  late Future<List<Map<String, dynamic>>> _paginatedActivityLog;



  int _pageNumber = 1;
  final int _pageSize = 10;
  int _totalPages = 0;
  List<Map<String, dynamic>> _accumulatedActivityLog = [];
  ScrollController? _mainVerticalController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _victimCountFuture = VictimServices.fetchVictimCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _volunteerCountFuture = VolunteerServices.fetchVolunteerCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _donationTotalFuture = DonationServices.fetchTotalQuantityFiltered(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
      currency: 'EUR',
    ).then((value) => value.toDouble());
    _completedTasksCountFuture = TaskServices.fetchTaskCountByStateFiltered(
      'Completed',
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );

    setState(() {
      _accumulatedActivityLog.clear();
      _pageNumber = 1;
      _totalPages = 1;
    });

    _paginatedActivityLog = getPaginatedActivityLog(_pageNumber, _pageSize).then((result) {
      setState(() {
        _accumulatedActivityLog.addAll(result['activityLog']);
        _pageNumber++;
        _totalPages = result['totalPages'];
      });
      return _accumulatedActivityLog;
    });
  }

  Future<Map<String, dynamic>> getPaginatedActivityLog(int pageNumber, int pageSize) async {
    final response = await DashboardServices.fetchRecentActivity(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
      pageNumber,
      pageSize,
    );
    
    var itemsKey = response.containsKey('activityLog') ? 'activityLog' : 'activityLog';
    var totalPagesKey = response.containsKey('TotalPages') ? 'TotalPages' : 'totalPages';
    
    List<Map<String, dynamic>> recentActivities = [];
    if (response.containsKey(itemsKey) && response[itemsKey] is List) {
      recentActivities = (response[itemsKey] as List)
          .map((activity) => activity as Map<String, dynamic>)
          .toList();
      
      print("Activity log list: $recentActivities");
      
      for (var activity in recentActivities) {
        print("Activity: $activity");
      }

      var totalCountKey = response.containsKey('TotalCount') ? 'TotalCount' : 'totalCount';
      var pageNumberKey = response.containsKey('PageNumber') ? 'PageNumber' : 'page';
      var pageSizeKey = response.containsKey('PageSize') ? 'PageSize' : 'size';
      var totalPagesKey = response.containsKey('TotalPages') ? 'TotalPages' : 'totalPages';

      print("Total Count: ${response[totalCountKey]}");
      print("Current Page: ${response[pageNumberKey]}");
      print("Page Size: ${response[pageSizeKey]}");
      print("Total Pages: ${response[totalPagesKey]}");
      
    } else {
      print("No items found in response: ${response.keys}");
    }
    
    return {
      'activityLog': recentActivities,
      'totalPages': response[totalPagesKey] ?? 1,
    };
  }

  @override
  void didUpdateWidget(covariant GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minContentWidth = math.max(1100.0, constraints.maxWidth);

        return TwoDimensionalScrollWidget(
          onVerticalControllerReady: (ctrl) => _mainVerticalController = ctrl,
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
                                  double value = snapshot.data ?? 0.0;
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
                            'Historial de actividad reciente',
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _paginatedActivityLog,
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
                final activityList = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activityList.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final item = activityList[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(item['type']),
                          child: Icon(_getTypeIcon(item['type']), color: Colors.white, size: 20),
                        ),
                        title: Text(
                          item['information'] ?? 'Sin información', 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item['date'] != null ? _formatDate(DateTime.parse(item['date'])) : 'Fecha desconocida',
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
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: (_pageNumber > _totalPages)
              ? null
              : () async {
                  final oldOffset = _mainVerticalController?.offset ?? 0.0;
                  
                  final result = await getPaginatedActivityLog(_pageNumber, _pageSize);
                  
                  setState(() {
                    _accumulatedActivityLog.addAll(result['activityLog']);
                    _pageNumber++;
                    _totalPages = result['totalPages'];
                  });
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_mainVerticalController?.hasClients ?? false) {
                      _mainVerticalController!.jumpTo(oldOffset);
                    }
                  });
                },
          icon: const Icon(Icons.refresh),
          label: const Text('Cargar más'),
          style: ElevatedButton.styleFrom(
            backgroundColor: (_pageNumber > _totalPages) 
                ? Colors.grey 
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ],
    );
  }

  String _buildRegistrationMessage(dynamic item) {
    String information = item['information'] ?? 'Información no disponible';
    return information;
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
      case 'donación física':
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
        return const Color.fromARGB(255, 255, 164, 163);
      case 'volunteer':
      case 'voluntario':
        return const Color(0xFFC62828);
      case 'donation':
      case 'donación':
      case 'donación física':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }
}
