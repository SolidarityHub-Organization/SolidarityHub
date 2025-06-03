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

        // Add the paginated volunteers list below the info card
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

// PaginatedVolunteersList widget
class PaginatedVolunteersList extends StatefulWidget {
  final int taskId;
  const PaginatedVolunteersList({required this.taskId, Key? key}) : super(key: key);

  @override
  State<PaginatedVolunteersList> createState() => _PaginatedVolunteersListState();
}

class _PaginatedVolunteersListState extends State<PaginatedVolunteersList> {
  int _pageNumber = 1;
  final int _pageSize = 5;
  int _totalCount = 0;
  bool _isLoading = false;
  List<dynamic> _volunteers = [];
  final DateTime _fromDate = DateTime(2000, 1, 1);
  final DateTime _toDate = DateTime(2100, 1, 1);
  // Keep track of the previous taskId to detect changes
  int? _previousTaskId;

  @override
  void initState() {
    super.initState();
    _fetchVolunteers(reset: true);
  }

  @override
  void didUpdateWidget(PaginatedVolunteersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if taskId changed
    if (widget.taskId != oldWidget.taskId) {
      // Reset and refetch data
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
      // If we're resetting, use page 1, otherwise use current page
      final pageToFetch = reset ? 1 : _pageNumber;
      
      final data = await TaskServices.fetchTaskVolunteersFilteredPaginated(
        taskId: widget.taskId,
        fromDate: _fromDate,
        toDate: _toDate,
        page: pageToFetch,
        size: _pageSize,
      );
      
      final items = data['items'] as List<dynamic>? ?? [];
      
      setState(() {
        // If resetting, replace volunteers; otherwise add to them
        if (reset) {
          _volunteers = items;
          _pageNumber = 2; // Next page will be 2
        } else {
          _volunteers.addAll(items);
          _pageNumber++;
        }
        
        _totalCount = data['totalCount'] ?? 0;
        _previousTaskId = widget.taskId;
      });
    } catch (e) {
      print('Error fetching volunteers: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _hasMore => _volunteers.length < _totalCount;

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
            else if (_volunteers.isEmpty)
              const Text('No hay voluntarios registrados.'),
            ..._volunteers.map((v) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person),
                  title: Text(v['name'] ?? 'Voluntario'),
                  subtitle: v['email'] != null ? Text(v['email']) : null,
                )),
            if (_hasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _isLoading ? null : () => _fetchVolunteers(reset: false),
                  child: _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Cargar más'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
