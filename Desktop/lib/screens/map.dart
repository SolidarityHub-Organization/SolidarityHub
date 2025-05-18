import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/services/location_external_services.dart';
import 'package:solidarityhub/services/location_services.dart';
import 'package:solidarityhub/widgets/map/factory_method_info/info_square_factory.dart';
import 'package:solidarityhub/services/affected_zone_services.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/models/affectedZone.dart';
import '../widgets/map/factory_method_markers/marker_factory.dart';
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/controllers/map/cluster_controller.dart';

class MapScreen extends StatefulWidget {
  final double? lat;
  final double? lng;
  final double? initialZoom;

  const MapScreen({Key? key, this.lat, this.lng, this.initialZoom}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MapViewMode { victim, volunteer, task, meeting_point, pickup_point, all }

final String baseUrl = 'http://localhost:5170';

class _MapScreenState extends State<MapScreen> {
  List<MapMarker> _mapMarkers = [];
  List<Polygon> _polygons = [];
  Set<MapViewMode> _selectedModes = {MapViewMode.victim, MapViewMode.volunteer, MapViewMode.task};
  MapMarker? _selectedMarker;
  bool _isHeatMapActive = false;
  double _currentZoom = 13.0;
  bool _clusteringEnabled = true; // Opción para habilitar/deshabilitar clusters

  late MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = widget.initialZoom ?? 13.0;
    _fetchLocations(LocationServices.fetchVictimLocations);
    _fetchLocations(LocationServices.fetchVolunteerLocations);
    _fetchLocations(LocationServices.fetchTaskLocations);
    _fetchLocations(LocationServices.fetchMeetingPointLocations);
    _fetchLocations(LocationServices.fetchPickupPointLocations);
    _fetchAffectedZones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations(Future<List<Map<String, dynamic>>> Function() fetcher) async {
    try {
      final locations = await fetcher();
      final markers = locations.map((j) => MapMarker.fromJson(j)).toList();
      setState(() => _mapMarkers.addAll(markers));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener ubicaciones: $e')));
      print(e);
    }
  }

  Future<void> _fetchAffectedZones() async {
    try {
      final zones = await AffectedZoneServices.fetchAffectedZones();

      setState(() {
        _polygons =
            zones.map((zoneData) {
              final zone = AffectedZone.fromJson(zoneData);

              return Polygon(
                points: zone.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
                color: _getHazardLevelColor(zone.hazardLevel).withOpacity(0.2),
                borderColor: _getHazardLevelColor(zone.hazardLevel),
                borderStrokeWidth: 3,
                isFilled: true,
                isDotted: false, // líneas sólidas para un look más moderno
              );
            }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener las zonas afectadas: $e')));
    }
  }

  Color _getHazardLevelColor(int hazardLevel) {
    switch (hazardLevel) {
      case 0: // Low
        return Color(0xFF008B8A);
      case 1: // Medium
        return Color(0xFFFF9600);
      case 2: // High
        return Color(0xFFE21C1C);
      case 3: // Critical
        return Color(0xFF460707);
      default:
        return Colors.grey;
    }
  }

  // Color del cluster según el tipo predominante
  Color _getClusterColor(String type) {
    switch (type) {
      case 'victim':
        return Colors.red.shade700;
      case 'volunteer':
        return Color.fromARGB(255, 255, 79, 135);
      case 'task':
        return Colors.orange;
      case 'meeting_point':
        return Colors.green;
      case 'pickup_point':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // filtering logic for multi-selection
    List<MapMarker> filteredMarkers =
        _mapMarkers.where((marker) {
          if (_selectedModes.isEmpty) return false;
          return _selectedModes.contains(_getMapViewMode(marker.type));
        }).toList();

    List<MapMarker> processedMarkers = [];
        
    Map<String, List<MapMarker>> markersByType = {};
    for (var marker in filteredMarkers) {
      if (!markersByType.containsKey(marker.type)) {
        markersByType[marker.type] = [];
      }
      markersByType[marker.type]!.add(marker);
    }

    for (var type in markersByType.keys) {
      processedMarkers.addAll(
        ClusterController.createClusters(
          markersByType[type]!,
          _currentZoom,
          _clusteringEnabled,
        )
      );
    }

    // Generar marcadores para el mapa
    List<Marker> flutterMapMarkers =
        processedMarkers.map((mapMarker) {
          if (mapMarker.isCluster) {
            return ClusterController.createClusterMarker(
              mapMarker,
              _onMarkerTapped, // Este parámetro ahora se ignorará en el controlador
              _currentZoom,
              (position, zoom) => _mapController.move(position, zoom),
              _getClusterColor,
            );
          } else {
            final creator = getMarkerCreator(mapMarker.type);
            return creator.createMarker(mapMarker, context, (MapMarker marker) => _onMarkerTapped(marker));
          }
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // set mins here
          final minWidth = 800.0;
          final minHeight = 600.0;
          final width = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
          final height = constraints.maxHeight < minHeight ? minHeight : constraints.maxHeight;

          return TwoDimensionalScrollWidget(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight, maxWidth: width, maxHeight: height),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(0, 3))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(
                                  widget.lat ?? 39.4699, // Default to Valencia if no position provided
                                  widget.lng ?? -0.3763,
                                ),
                                initialZoom: widget.initialZoom ?? 13.0,
                                interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                                onMapReady: () {
                                  // Asegurarnos de que el mapa se centre en la ubicación correcta
                                  if (widget.lat != null && widget.lng != null) {
                                    _mapController.move(LatLng(widget.lat!, widget.lng!), widget.initialZoom ?? 15.0);
                                  }
                                },
                                onPositionChanged: (position, hasGesture) {
                                  // Actualizar el zoom current
                                  if (_currentZoom != position.zoom) {
                                    setState(() {
                                      _currentZoom = position.zoom!;
                                    });
                                  }
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                  subdomains: ['a', 'b', 'c', 'd'],
                                  retinaMode: RetinaMode.isHighDensity(context),
                                ),
                                PolygonLayer(polygons: _isHeatMapActive ? _polygons : []),
                                MarkerLayer(markers: flutterMapMarkers),
                              ],
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar dirección...',
                                    prefixIcon: IconButton(
                                      icon: Icon(Icons.search, color: Colors.red.shade700),
                                      onPressed: () {
                                        _searchAddress(_searchController.text);
                                      },
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.clear, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  onSubmitted: (value) {
                                    _searchAddress(value);
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 82,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFilterButton(
                                    label: 'Afectados',
                                    isSelected: _selectedModes.contains(MapViewMode.victim),
                                    onPressed: () => _toggleViewMode(MapViewMode.victim),
                                    icon: Icons.people,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 8),
                                  _buildFilterButton(
                                    label: 'Voluntarios',
                                    isSelected: _selectedModes.contains(MapViewMode.volunteer),
                                    onPressed: () => _toggleViewMode(MapViewMode.volunteer),
                                    icon: Icons.volunteer_activism,
                                    color: Color.fromARGB(255, 255, 79, 135),
                                  ),
                                  SizedBox(height: 8),
                                  _buildFilterButton(
                                    label: 'Tareas',
                                    isSelected: _selectedModes.contains(MapViewMode.task),
                                    onPressed: () => _toggleViewMode(MapViewMode.task),
                                    icon: Icons.task,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(height: 8),
                                  _buildFilterButton(
                                    label: 'Puntos de Encuentro',
                                    isSelected: _selectedModes.contains(MapViewMode.meeting_point),
                                    onPressed: () => _toggleViewMode(MapViewMode.meeting_point),
                                    icon: Icons.group, // add icon for this?
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  _buildFilterButton(
                                    label: 'Puntos de Recogida',
                                    isSelected: _selectedModes.contains(MapViewMode.pickup_point),
                                    onPressed: () => _toggleViewMode(MapViewMode.pickup_point),
                                    icon: Icons.local_shipping, // add icon for this?
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFilterButton(
                                    label: 'Mapa de Calor',
                                    isSelected: _isHeatMapActive,
                                    onPressed: () {
                                      setState(() {
                                        _isHeatMapActive = !_isHeatMapActive;
                                      });
                                    },
                                    icon: Icons.heat_pump,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                            if (_isHeatMapActive)
                              Positioned(
                                bottom: 70,
                                left: 16,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nivel de Peligro",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      _buildLegendHeat("Bajo", Color(0xFF008B8A)),
                                      _buildLegendHeat("Medio", Color(0xFFFF9600)),
                                      _buildLegendHeat("Alto", Color(0xFFE21C1C)),
                                      _buildLegendHeat("Crítico", Color(0xFF460707)),
                                    ],
                                  ),
                                ),
                              ),
                            // Leyenda de colores para marcadores de afectados
                            if (_selectedModes.contains(MapViewMode.victim))
                              Positioned(
                                bottom: 16,
                                right: 16, // Mantener en la derecha
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Urgencia Afectados",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      _buildLegendItem(Colors.grey, "Desconocido"),
                                      _buildLegendItem(Colors.green, "Bajo"),
                                      _buildLegendItem(Colors.orange, "Medio"),
                                      _buildLegendItem(Color.fromARGB(255, 255, 0, 0), "Alto"),
                                      _buildLegendItem(Color.fromARGB(255, 139, 0, 0), "Crítico"),
                                    ],
                                  ),
                                ),
                              ),

                            // Leyenda de colores e iconos para tareas
                            if (_selectedModes.contains(MapViewMode.task))
                              Positioned(
                                bottom: _selectedModes.contains(MapViewMode.victim) ? 250 : 16,
                                right: 16, // Mantener en la derecha
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Estado de Tareas",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      _buildTaskLegendItem(
                                        icon: Icons.assignment_turned_in_rounded,
                                        color: Colors.green,
                                        label: "Completado",
                                      ),
                                      _buildTaskLegendItem(
                                        icon: Icons.assignment_outlined,
                                        color: Colors.orange,
                                        label: "Asignado",
                                      ),
                                      _buildTaskLegendItem(
                                        icon: Icons.assignment_return_rounded,
                                        color: Colors.blue,
                                        label: "Pendiente",
                                      ),
                                      _buildTaskLegendItem(
                                        icon: Icons.assignment_late_outlined,
                                        color: Colors.red,
                                        label: "Cancelado",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ternary operator instead of if statement
                  _selectedMarker != null
                      ? Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          height: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Información",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: Colors.red.shade700, size: 28),
                                        onPressed: () {
                                          setState(() {
                                            _selectedMarker = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(minHeight: 725),
                                  child: getInfoSquare(_selectedMarker!.type).buildInfoSquare(_selectedMarker!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : Container(), // empty when no marker is selected
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleViewMode(MapViewMode mode) {
    setState(() {
      if (_selectedModes.contains(mode)) {
        _selectedModes.remove(mode);
      } else {
        _selectedModes.add(mode);
      }

      // clear marker when changing filters
      _selectedMarker = null;
    });
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
    required IconData icon,
    Color color = Colors.blue,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMarkerTapped(MapMarker marker) {
    setState(() {
      _selectedMarker = marker;
    });
  }

  // Widget para construir un elemento de la leyenda
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_pin, color: color, size: 24),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Widget para construir un elemento de la leyenda de tareas
  Widget _buildTaskLegendItem({required IconData icon, required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, color: color, size: 24), SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 12))],
      ),
    );
  }

  void _searchAddress(String value) {
    if (value.trim().isEmpty) return;

    LocationExternalServices.getLatLonFromAddress(value).then((result) {
      if (result != null) {
        final location = result['location'] as LatLng;
        final zoomLevel = result['zoomLevel'] as double;
        _mapController.move(location, zoomLevel);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dirección no encontrada')));
      }
    });
  }

  MapViewMode _getMapViewMode(String type) {
    switch (type) {
      case 'victim':
        return MapViewMode.victim;
      case 'volunteer':
        return MapViewMode.volunteer;
      case 'task':
        return MapViewMode.task;
      case 'meeting_point':
        return MapViewMode.meeting_point;
      case 'pickup_point':
        return MapViewMode.pickup_point;
      default:
        return MapViewMode.all;
    }
  }

  Widget _buildLegendHeat(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
