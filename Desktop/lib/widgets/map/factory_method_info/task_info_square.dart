import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorator/info_square_decorator.dart';
import '../../../services/task_services.dart';

class TaskInfoSquare implements InfoSquare {
  // Método para obtener el icono según el estado
  IconData _getStateIcon(String? state) {
    if (state == null) return Icons.assignment_outlined;

    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Icons.assignment_turned_in_rounded;
      case 'asignado':
        return Icons.assignment_outlined;
      case 'pendiente':
        return Icons.assignment_return_rounded;
      case 'cancelado':
        return Icons.assignment_late_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  // Método para obtener el color según el estado
  Color _getStateColor(String? state) {
    if (state == null) return Colors.orange;

    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Colors.green;
      case 'asignado':
        return Colors.orange;
      case 'pendiente':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para tareas
        final Color primaryColor = Colors.orange;
        final Color secondaryColor = Colors.orange.shade300;
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.description, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
          InfoRowData(
            icon: Icons.gps_fixed,
            label: 'Coordenadas',
            value:
                '${mapMarker.position.latitude.toStringAsFixed(6)}, ${mapMarker.position.longitude.toStringAsFixed(6)}',
          ),
        ];

        // Agregar estado si existe
        if (mapMarker.state != null) {
          rows.add(
            InfoRowData(
              icon: _getStateIcon(mapMarker.state),
              label: 'Estado',
              value: mapMarker.state!,
              valueColor: _getStateColor(mapMarker.state),
            ),
          );
        }

        // Agregar habilidades si existen
        if (mapMarker.skillsWithLevel != null) {
          rows.add(
            InfoRowData(
              icon: Icons.star,
              label: 'Habilidades',
              value: mapMarker.skillsWithLevel!.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
            ),
          );
        }

        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: 'Detalles de la tarea',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.task_alt,
          rows: rows,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            decoratedSquare.buildInfoSquare(mapMarker),
            const SizedBox(height: 12),
            PaginatedVolunteersList(taskId: int.tryParse(mapMarker.id.toString()) ?? 0),
          ],
        );
      },
    );
  }
}

class PaginatedVolunteersList extends StatefulWidget {
  final int taskId;
  const PaginatedVolunteersList({required this.taskId, Key? key}) : super(key: key);

  @override
  State<PaginatedVolunteersList> createState() => _PaginatedVolunteersListState();
}

class _PaginatedVolunteersListState extends State<PaginatedVolunteersList> {
  int _pageNumber = 1;
  final int _pageSize = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  List<dynamic> _volunteers = [];
  final DateTime _fromDate = DateTime(2000, 1, 1);
  final DateTime _toDate = DateTime(2100, 1, 1);
  int? _previousTaskId;

  @override
  void initState() {
    super.initState();
    _fetchVolunteers(reset: true);
  }

  @override
  void didUpdateWidget(PaginatedVolunteersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskId != oldWidget.taskId) {
      _resetAndFetch();
    }
  }

  void _resetAndFetch() {
    setState(() {
      _pageNumber = 1;
      _totalCount = 0;
      _volunteers = [];
    });
    _fetchVolunteers(reset: true);
  }

  Future<void> _fetchVolunteers({bool reset = false}) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      final pageToFetch = reset ? 1 : _pageNumber;
      
      /*
      print('=== FETCH VOLUNTEERS DEBUG ===');
      print('Task ID: ${widget.taskId}');
      print('Page to fetch: $pageToFetch');
      print('Page size: $_pageSize');
      print('Current volunteers count: ${_volunteers.length}');
      print('Current total count: $_totalCount');
      */
      
      final data = await TaskServices.fetchTaskVolunteersFilteredPaginated(
        taskId: widget.taskId,
        fromDate: _fromDate,
        toDate: _toDate,
        page: pageToFetch,
        size: _pageSize,
      );
      
      print('=== API RESPONSE ===');
      print('Full response: $data');
      print('Response type: ${data.runtimeType}');
      
      if (data['items'] != null) {
        print('Items type: ${data['items'].runtimeType}');
        print('Items length: ${data['items'].length}');
        print('Items content:');
        for (int i = 0; i < data['items'].length; i++) {
          print('  Item $i: ${data['items'][i]}');
        }
      } else {
        print('Items is null!');
      }
      
      if (data['totalCount'] != null) {
        print('Total count: ${data['totalCount']} (type: ${data['totalCount'].runtimeType})');
      } else {
        print('Total count is null!');
      }
      
      //print('=== PROCESSING ===');
      final items = data['items'] as List<dynamic>? ?? [];
      final totalCount = data['totalCount'] as int? ?? 0;
      
      //print('Processed items length: ${items.length}');
      //print('Processed total count: $totalCount');
      
      // final limitedItems = items.take(_pageSize).toList();
      final limitedItems = items;
      
      setState(() {
        if (reset) {
          _volunteers = limitedItems;
          _pageNumber = 2;
        } else {
          _volunteers.addAll(limitedItems);
          _pageNumber++;
        }
        
        _totalCount = totalCount;
        _previousTaskId = widget.taskId;
      });
      
      /*
      print('=== STATE AFTER UPDATE ===');
      print('Volunteers in state: ${_volunteers.length}');
      print('Next page number: $_pageNumber');
      print('Total count: $_totalCount');
      print('Has more: $_hasMore');
      print('=== END DEBUG ===\n');
      */
      
    } catch (e) {
      print('Error fetching volunteers: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _hasMore {
    final hasMore = _volunteers.length < _totalCount && _totalCount > 0;
    //print('_hasMore check: volunteers=${_volunteers.length}, total=$_totalCount, hasMore=$hasMore');
    return hasMore;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.people, color: Colors.orange),
                SizedBox(width: 8),
                Text('Voluntarios asignados', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_isLoading && _volunteers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_volunteers.isEmpty && !_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No hay voluntarios registrados.'),
              ),
            
            ..._volunteers.map((v) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person),
                  title: Text(v['name'] ?? 'Voluntario'),
                  subtitle: v['email'] != null ? Text(v['email']) : null,
                )),
            
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: (_isLoading || !_hasMore) ? null : () => _fetchVolunteers(reset: false),
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 16, 
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Cargando...' : 'Cargar más'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasMore ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
