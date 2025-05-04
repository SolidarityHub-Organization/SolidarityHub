import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/services/task_service.dart';
import 'package:solidarityhub/LogicPresentation/map/infoSquareFactory.dart';
import '../../services/victimServices.dart';
import '../../services/volunteer_service.dart';
import '../../services/affectedZoneServices.dart';
import '../../models/mapMarker.dart';
import '../../models/affectedZone.dart';
import 'markerfactory.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MapViewMode { victim, volunteer, task, all }

final String baseUrl = 'http://localhost:5170';

class _MapScreenState extends State<MapScreen> {
  List<MapMarker> _mapMarkers = [];
  List<Polygon> _polygons = [];
  MapViewMode _currentMode = MapViewMode.all;
  MapMarker? _selectedMarker;

  final VictimService _victimServices = VictimService(baseUrl);
  final AffectedZoneServices _affectedZoneServices = AffectedZoneServices(baseUrl);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchVictimLocations();
    _fetchVolunteerLocations();
    _fetchAffectedZones();
    _fetchTaskLocations();
  }

  Future<void> _fetchVictimLocations() async {
    try {
      final locations = await _victimServices.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      setState(() {
        _mapMarkers.addAll(mapMarkers);
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener las ubicaciones: $e')));
      print('Error al obtener las ubicaciones: $e');
    }
  }

  Future<void> _fetchVolunteerLocations() async {
    try {
      final locations = await VolunteerService.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      setState(() {
        _mapMarkers.addAll(mapMarkers);
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener las ubicaciones: $e')));
      print('Error al obtener las ubicaciones: $e');
    }
  }

  Future<void> _fetchTaskLocations() async {
    try {
      final locations = await TaskService.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      setState(() {
        _mapMarkers.addAll(mapMarkers);
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener las ubicaciones: $e')));
      print('Error al obtener las ubicaciones: $e');
    }
  }

  Future<void> _fetchAffectedZones() async {
    try {
      final zones = await _affectedZoneServices.fetchAffectedZones();

      setState(() {
        _polygons =
            zones.map((zoneData) {
              final zone = AffectedZone.fromJson(zoneData);

              return Polygon(
                points: zone.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
                color: _getHazardLevelColor(zone.hazardLevel).withOpacity(0.3),
                borderColor: _getHazardLevelColor(zone.hazardLevel),
                borderStrokeWidth: 2,
                isDotted: true,
              );
            }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener las zonas afectadas: $e')));
    }
  }

  Color _getHazardLevelColor(int hazardLevel) {
    switch (hazardLevel) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtramos los marcadores según el modo seleccionado
    List<MapMarker> filteredMarkers =
        _mapMarkers.where((marker) {
          switch (_currentMode) {
            case MapViewMode.all:
              return true; // Mostrar todos los marcadores
            case MapViewMode.victim:
              return marker.type == 'victim'; // Solo mostrar víctimas
            case MapViewMode.volunteer:
              return marker.type == 'volunteer'; // Solo mostrar voluntarios
            case MapViewMode.task:
              return marker.type == 'task'; // Solo mostrar tareas
          }
        }).toList();

    // Usamos los marcadores filtrados para crear los Marker de flutter_map
    List<Marker> flutterMapMarkers =
        filteredMarkers.map((mapMarker) {
          final creator = getMarkerCreator(mapMarker.type);
          return creator.createMarker(mapMarker, context, (MapMarker marker) => _onMarkerTapped(marker));
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // El mapa ocupará una parte del ancho, ahora con márgenes
          Expanded(
            flex: 2, // Reducido de 3 a 2 para hacer más espacio para el panel de información
            child: Container(
              margin: EdgeInsets.all(12.0), // Añadimos un margen alrededor del mapa
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(0, 3))],
              ),
              child: ClipRRect(
                // Recortamos el mapa para que respete el borderRadius
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(39.47391, -0.37966),
                        initialZoom: 13,
                        // Añadidos parámetros para mejorar interactividad
                        interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: ['a', 'b', 'c', 'd'],
                        ),
                        PolygonLayer(polygons: _polygons),
                        MarkerLayer(markers: flutterMapMarkers),
                      ],
                    ),
                    // Botones de filtrado en la esquina superior izquierda
                    Positioned(
                      top: 16,
                      left: 16, // Cambiado de right a left para ubicarlos a la izquierda
                      child: Column(
                        children: [
                          _buildFilterButton(
                            label: 'Todos',
                            isSelected: _currentMode == MapViewMode.all,
                            onPressed: () => _setViewMode(MapViewMode.all),
                            icon: Icons.map,
                          ),
                          SizedBox(height: 8),
                          _buildFilterButton(
                            label: 'Afectados',
                            isSelected: _currentMode == MapViewMode.victim,
                            onPressed: () => _setViewMode(MapViewMode.victim),
                            icon: Icons.people,
                            color: Color.fromARGB(255, 43, 210, 252),
                          ),
                          SizedBox(height: 8),
                          _buildFilterButton(
                            label: 'Voluntarios',
                            isSelected: _currentMode == MapViewMode.volunteer,
                            onPressed: () => _setViewMode(MapViewMode.volunteer),
                            icon: Icons.volunteer_activism,
                            color: Colors.green,
                          ),
                          SizedBox(height: 8),
                          _buildFilterButton(
                            label: 'Tareas',
                            isSelected: _currentMode == MapViewMode.task,
                            onPressed: () => _setViewMode(MapViewMode.task),
                            icon: Icons.task,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Panel de información lateral (solo visible cuando hay un marcador seleccionado)
          if (_selectedMarker != null)
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16.0), // Aumentado el padding
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(bottom: 20.0), // Más espacio inferior
                        margin: EdgeInsets.only(bottom: 10.0), // Margen inferior
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Información",
                              style: TextStyle(
                                fontSize: 28, // Texto más grande
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade700,
                                size: 28, // Icono más grande
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedMarker = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // Widget de información con contenedor más grande
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 350, // Altura mínima más grande
                        ),
                        child: getInfoSquare(_selectedMarker!.type).buildInfoSquare(_selectedMarker!),
                      ),
                      SizedBox(height: 24), // Más espacio
                      // Información adicional con contenedor más grande
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 150, // Altura mínima más grande para acciones
                        ),
                        padding: EdgeInsets.all(20), // Padding más grande
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, 3), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Acciones disponibles",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22, // Texto más grande
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 20), // Más espacio
                            _buildActionButton("Contactar", Icons.phone, Colors.green, () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método para construir botones de acción en el panel de información
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  void _setViewMode(MapViewMode mode) {
    setState(() {
      _currentMode = mode;
      // Cuando cambiamos el modo, limpiamos el marcador seleccionado
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
}
