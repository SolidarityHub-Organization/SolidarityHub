import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/imap_component.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/controllers/map/cluster_controller.dart';
import 'package:solidarityhub/services/location_services.dart';
import 'package:solidarityhub/services/location_external_services.dart';
import 'package:solidarityhub/services/affected_zone_services.dart';
import 'package:solidarityhub/services/route_services.dart';
import 'package:solidarityhub/utils/route_result.dart';

// Enumeración para los modos de visualización del mapa
enum MapViewMode { victim, volunteer, task, meeting_point, pickup_point }

// Enumeración para los tipos de rutas
enum TypeofRoute { car, walking, bike }

// Modelo para los polígonos del mapa de calor
class MapPolygon {
  final List<LatLng> points;
  final Color color;
  final Color borderColor;
  final double borderStrokeWidth;

  MapPolygon({required this.points, required this.color, required this.borderColor, this.borderStrokeWidth = 1.0});
}

class MapScreenController extends ChangeNotifier {
  // Marcadores por tipo
  final Map<String, List<MapMarker>> _markers = {
    'victim': [],
    'volunteer': [],
    'task': [],
    'meeting_point': [],
    'pickup_point': [],
  };

  // Filtros activos
  final Set<MapViewMode> _selectedModes = {MapViewMode.victim}; // Por defecto mostrar víctimas

  //Tipo de rutas seleccionada
  TypeofRoute? _selectedRouteType = TypeofRoute.car; // Por defecto tipo de ruta coche

  // Componente seleccionado (puede ser MapMarker o MapMarkerCluster)
  IMapComponent? _selectedMarker;

  // Estado del mapa de calor
  bool _isHeatMapActive = false;

// Estado del mapa de rutas
  bool _isRouteMapActive = false;

// Variables para el mapa de rutas
  LatLng? _routeStart;
  LatLng? _routeEnd;
  List<LatLng> _routePoints = [];
  double? _routeDistance;
  double? _routeDuration;
  RouteResult? _routeResult;

  // Nivel de zoom actual
  double _currentZoom = 13.0;

  // Polígonos para el mapa de calor
  List<MapPolygon> _polygons = [];
  // Getters
  Set<MapViewMode> get selectedModes => _selectedModes;
  IMapComponent? get selectedMarker => _selectedMarker;
  bool get isHeatMapActive => _isHeatMapActive;
  bool get isRouteMapActive => _isRouteMapActive;
  double get currentZoom => _currentZoom;
  List<MapPolygon> get polygons => _polygons;
  LatLng? get routeStart => _routeStart;
  LatLng? get routeEnd => _routeEnd;
  List<LatLng> get routePoints => _routePoints;
  TypeofRoute? get selectedRouteType => _selectedRouteType;
  double? get routeDistance => _routeDistance;
  double? get routeDuration => _routeDuration;
  RouteResult? get routeResult => _routeResult;
  

  // Constructor
  MapScreenController();

  // Actualizar el nivel de zoom
  void updateZoom(double zoom) {
    if (_currentZoom != zoom) {
      _currentZoom = zoom;
      notifyListeners();
    }
  }  // Seleccionar un componente del mapa (marcador o cluster)
  void selectMarker(IMapComponent component) {
    // Ahora podemos asignar directamente cualquier IMapComponent
    _selectedMarker = component;
    notifyListeners();
  }

  // Limpiar el componente seleccionado
  void clearSelectedMarker() {
    _selectedMarker = null;
    notifyListeners();
  }

  // Cambiar el modo de visualización
  void toggleViewMode(MapViewMode mode) {
    if (_selectedModes.contains(mode)) {
      _selectedModes.remove(mode);
    } else {
      _selectedModes.add(mode);
    }
    notifyListeners();
  }

  // Activar/desactivar el mapa de calor
  void toggleHeatMap() {
    _isHeatMapActive = !_isHeatMapActive;
    if (_isHeatMapActive) {
      // Mostrar un indicador de carga mientras se generan los datos
      _polygons = []; // Limpiar los polígonos actuales
      notifyListeners();
      // Generar los polígonos de forma asíncrona
      _generateHeatMap();
    } else {
      // Si se desactiva, notificar inmediatamente
      notifyListeners();
    }
  }

  // Generar los polígonos para el mapa de calor
  Future<void> _generateHeatMap() async {
    try {
      // Obtener las zonas afectadas del servicio
      final List<Map<String, dynamic>> affectedZones = await AffectedZoneServices.fetchAffectedZones();

      // Convertir las zonas afectadas a polígonos para el mapa
      _polygons = _convertAffectedZonesToPolygons(affectedZones);

      // Notificar a los oyentes para actualizar la UI
      notifyListeners();
    } catch (e) {
      print('Error cargando zonas afectadas: $e');
      // Si hay error, usar polígonos de ejemplo como fallback
      _polygons = _createSampleHeatMap();
      notifyListeners();
    }
  }

  void setRouteType(TypeofRoute type) {
    _selectedRouteType = type;
    notifyListeners();
  }

  void toggleRouteMap( BuildContext context){
    _isRouteMapActive = !_isRouteMapActive;
    if (_isRouteMapActive) {
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona el punto de partida y luego el de llegada en el mapa.')),
      );     
    } else {
      _routeStart = null;
      _routeEnd = null;
      _routePoints = [];
      notifyListeners();
    }
  }

  Future<void> generateRouteMap(TapPosition tapPosition, LatLng point, BuildContext context) async {
    if(_routeStart == null){
       _routeStart = point;
       notifyListeners();
       ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ahora selecciona el punto de llegada.')),
          );
    } else if (_routeEnd == null){
      _routeEnd = point;
      notifyListeners();
      await _calculateRoute(context);
      }  
  }

  Future<void> _calculateRoute(BuildContext context) async {
  if (_routeStart != null && _routeEnd != null) {
    final List<List<LatLng>> zonasAEvitar = await AffectedZoneServices.fetchAffectedZonesPoints();
    
    // Check if start or end point is in affected zone
    bool startInAffectedZone = _isPointInAffectedZone(_routeStart!, zonasAEvitar);
    bool endInAffectedZone = _isPointInAffectedZone(_routeEnd!, zonasAEvitar);
    
    // If either start or end is in affected zone, don't avoid affected zones
    final zonesToAvoid = (startInAffectedZone || endInAffectedZone) ? <List<LatLng>>[] : zonasAEvitar;
    
    try {
      switch (_selectedRouteType) {
        case TypeofRoute.car:
          _routeResult = await RouteServices.fetchCarRoute(_routeStart!, _routeEnd!, zonesToAvoid);
          _routePoints = _routeResult!.points;
          _routeDistance = _routeResult!.distance;
          _routeDuration = _routeResult!.duration;
          break;
        case TypeofRoute.walking:
          _routeResult = await RouteServices.fetchWalkingRoute(_routeStart!, _routeEnd!, zonesToAvoid);
          _routePoints = _routeResult!.points;
          _routeDistance = _routeResult!.distance;
          _routeDuration = _routeResult!.duration;
          break;
        case TypeofRoute.bike:
          _routeResult = await RouteServices.fetchBikeRoute(_routeStart!, _routeEnd!, zonesToAvoid);
          _routePoints = _routeResult!.points;
          _routeDistance = _routeResult!.distance;
          _routeDuration = _routeResult!.duration;
          break;
        default:
          throw Exception('Tipo de ruta no soportado');
      }
      
      // Show message if routing through affected zones
      if (startInAffectedZone || endInAffectedZone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ruta calculada a través de zonas afectadas debido a que el origen o destino está en una zona afectada.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al calcular ruta: $e')),
      );
    }
  }
}

// Update this method to accept List<List<LatLng>>
bool _isPointInAffectedZone(LatLng point, List<List<LatLng>> affectedZones) {
  for (var polygonPoints in affectedZones) {
    if (polygonPoints.length >= 3 && _isPointInPolygon(point, polygonPoints)) {
      return true;
    }
  }
  return false;
}

// Add this method for point-in-polygon calculation
bool _isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {
  int intersections = 0;
  for (int i = 0; i < polygonPoints.length; i++) {
    int j = (i + 1) % polygonPoints.length;
    
    if ((polygonPoints[i].latitude > point.latitude) != (polygonPoints[j].latitude > point.latitude) &&
        point.longitude < (polygonPoints[j].longitude - polygonPoints[i].longitude) * 
        (point.latitude - polygonPoints[i].latitude) / 
        (polygonPoints[j].latitude - polygonPoints[i].latitude) + polygonPoints[i].longitude) {
      intersections++;
    }
  }
  return intersections % 2 == 1;
}
  // Convertir zonas afectadas a polígonos
  List<MapPolygon> _convertAffectedZonesToPolygons(List<Map<String, dynamic>> affectedZones) {
    final polygons = <MapPolygon>[];

    for (var zone in affectedZones) {
      // Convertir puntos a formato LatLng
      List<dynamic> pointsData = zone['points'];
      List<LatLng> points =
          pointsData.map((point) {
            return LatLng(double.parse(point['latitude'].toString()), double.parse(point['longitude'].toString()));
          }).toList();

      // Determinar el color según el nivel de peligro
      Color color;
      Color borderColor;

      switch (zone['hazard_level'].toString().toLowerCase()) {
        case 'high':
        case 'alto':
        case '3':
          color = Colors.red.withOpacity(0.5); // Más opacidad para zonas rojas (alto riesgo)
          borderColor = Colors.red;
          break;
        case 'medium':
        case 'medio':
        case '2':
          color = Colors.orange.withOpacity(0.4); // Opacidad media para zonas naranjas
          borderColor = Colors.orangeAccent;
          break;
        case 'low':
        case 'bajo':
        case '1':
          color = Colors.yellow.withOpacity(0.3); // Opacidad baja pero visible para zonas amarillas
          borderColor = Colors.yellowAccent;
          break;
        default:
          color = Colors.grey.withOpacity(0.35); // Opacidad para zonas sin nivel definido
          borderColor = Colors.grey;
      } // Añadir el polígono si tiene al menos 3 puntos (mínimo para formar un polígono)
      if (points.length >= 3) {
        polygons.add(
          MapPolygon(
            points: points,
            color: color, // Color con transparencia para el relleno
            borderColor: borderColor,
            borderStrokeWidth: 1.5, // Hacemos el borde un poco más grueso para mejor visibilidad
          ),
        );
      }
    }

    return polygons;
  }

  // Crear polígonos de ejemplo para el mapa de calor (fallback)
  List<MapPolygon> _createSampleHeatMap() {
    final polygons = <MapPolygon>[]; // Áreas de alta densidad
    polygons.add(
      MapPolygon(
        points: [LatLng(39.47, -0.377), LatLng(39.47, -0.374), LatLng(39.468, -0.374), LatLng(39.468, -0.377)],
        color: Colors.red.withOpacity(0.5), // Mayor opacidad para zonas rojas
        borderColor: Colors.red,
        borderStrokeWidth: 1.5,
      ),
    );

    // Áreas de media densidad
    polygons.add(
      MapPolygon(
        points: [LatLng(39.465, -0.38), LatLng(39.465, -0.376), LatLng(39.462, -0.376), LatLng(39.462, -0.38)],
        color: Colors.orange.withOpacity(0.4), // Opacidad media
        borderColor: Colors.orangeAccent,
        borderStrokeWidth: 1.5,
      ),
    );

    // Áreas de baja densidad
    polygons.add(
      MapPolygon(
        points: [LatLng(39.475, -0.37), LatLng(39.475, -0.365), LatLng(39.47, -0.365), LatLng(39.47, -0.37)],
        color: Colors.yellow.withOpacity(0.3), // Opacidad baja pero visible
        borderColor: Colors.yellowAccent,
        borderStrokeWidth: 1.5,
      ),
    );

    // Áreas sin nivel definido
    polygons.add(
      MapPolygon(
        points: [LatLng(39.48, -0.38), LatLng(39.48, -0.375), LatLng(39.478, -0.375), LatLng(39.478, -0.38)],
        color: Colors.grey.withOpacity(0.35), // Opacidad para zonas sin nivel definido
        borderColor: Colors.grey,
        borderStrokeWidth: 1.5,
      ),
    );

    return polygons;
  }


  // Obtener el color para un cluster basado en sus elementos
  Color getClusterColor(List<IMapComponent> items) {
    if (items.isEmpty) return Colors.grey;

    // Contar los tipos en el cluster
    Map<String, int> typeCounts = {};
    for (var item in items) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
    }

    // Encontrar el tipo predominante
    String dominantType = 'victim';
    int maxCount = 0;
    typeCounts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantType = type;
      }
    });

    // Asignar color según el tipo predominante
    switch (dominantType) {
      case 'victim':
        return Colors.red;
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
  // Obtener los marcadores filtrados y procesados según los filtros activos
  List<IMapComponent> getFilteredAndProcessedMarkers() {
    List<IMapComponent> filteredMarkers = [];

    // Filtrar por los modos seleccionados
    if (_selectedModes.contains(MapViewMode.victim)) {
      filteredMarkers.addAll(_markers['victim'] ?? []);
    }
    if (_selectedModes.contains(MapViewMode.volunteer)) {
      filteredMarkers.addAll(_markers['volunteer'] ?? []);
    }
    if (_selectedModes.contains(MapViewMode.task)) {
      filteredMarkers.addAll(_markers['task'] ?? []);
    }
    if (_selectedModes.contains(MapViewMode.meeting_point)) {
      filteredMarkers.addAll(_markers['meeting_point'] ?? []);
    }
    if (_selectedModes.contains(MapViewMode.pickup_point)) {
      filteredMarkers.addAll(_markers['pickup_point'] ?? []);
    }

    // Aplicar clustering basado en el nivel de zoom    // A menor zoom, más agresivo el clustering
    // En zoom muy bajo, creamos un único cluster global
    if (_currentZoom < 10) {
      return ClusterController.clusterMarkers(
        filteredMarkers, 
        _currentZoom,
        markerClusterDistance: 0.1 * pow(2, 16 - _currentZoom) / 125,
        clusterClusterDistance: 0.2 * pow(2, 16 - _currentZoom) / 125,
        maxLevels: 3 
      );
    }
    // En zoom medio-bajo, aplicamos clustering normal si hay suficientes elementos
    else if (_currentZoom < 13 && filteredMarkers.length > 3) {
      return ClusterController.clusterMarkers(
        filteredMarkers, 
        _currentZoom,
        markerClusterDistance: 0.05 * pow(2, 16 - _currentZoom) / 125,
        clusterClusterDistance: 0.1 * pow(2, 16 - _currentZoom) / 125,
        maxLevels: 2
      );
    }

    // Si el zoom es alto o hay pocos marcadores, mostramos marcadores individuales
    return filteredMarkers;
  }

  // Cargar todos los datos necesarios para el mapa
  Future<void> fetchAllData() async {
    await Future.wait([
      _fetchVictims(),
      _fetchVolunteers(),
      _fetchTasks(),
      _fetchMeetingPoints(),
      _fetchPickupPoints(),
    ]);
    notifyListeners();
  }

  // Buscar una dirección y devolver sus coordenadas
  Future<Map<String, dynamic>?> searchAddress(String address) async {
    try {
      // Utilizamos el servicio externo de localización para evitar código duplicado
      final location = await LocationExternalServices.getLatLngFromAddress(address);

      if (location != null) {
        return {'location': location, 'zoomLevel': 16.0};
      }
      return null;
    } catch (e) {
      print('Error buscando dirección: $e');
      return null;
    }
  }

  // Traducir nivel de urgencia a español
  String traducirNivelUrgencia(String? nivel) {
    if (nivel == null) return "Desconocido";

    switch (nivel.toLowerCase()) {
      case 'low':
        return 'Bajo';
      case 'medium':
        return 'Medio';
      case 'high':
        return 'Alto';
      case 'critical':
        return 'Crítico';
      case 'unknown':
        return 'Desconocido';
      default:
        return nivel;
    }
  }

  // Traducir estado de tarea a español
  String traducirEstadoTarea(String? estado) {
    if (estado == null) return "Pendiente";

    switch (estado.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'assigned':
        return 'Asignada';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  // Funciones para cargar datos desde la API
  Future<void> _fetchVictims() async {
    try {
      final locations = await LocationServices.fetchVictimLocations();

      _markers['victim'] =
          locations
              .map(
                (location) => MapMarker(
                  id: location['id']?.toString() ?? '',
                  name: location['name'] ?? 'Sin nombre',
                  position: LatLng(
                    double.parse(location['latitude'].toString()),
                    double.parse(location['longitude'].toString()),
                  ),
                  type: 'victim',
                  urgencyLevel: traducirNivelUrgencia(location['urgencyLevel']),
                ),
              )
              .toList();
    } catch (e) {
      print('Error cargando víctimas: $e');
    }
  }

  Future<void> _fetchVolunteers() async {
    try {
      final locations = await LocationServices.fetchVolunteerLocations();

      _markers['volunteer'] =
          locations
              .map(
                (location) => MapMarker(
                  id: location['id']?.toString() ?? '',
                  name: location['name'] ?? 'Sin nombre',
                  position: LatLng(
                    double.parse(location['latitude'].toString()),
                    double.parse(location['longitude'].toString()),
                  ),
                  type: 'volunteer',
                ),
              )
              .toList();
    } catch (e) {
      print('Error cargando voluntarios: $e');
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final locations = await LocationServices.fetchTaskLocations();

      _markers['task'] =
          locations
              .map(
                (location) => MapMarker(
                  id: location['id']?.toString() ?? '',
                  name: location['name'] ?? 'Sin nombre',
                  position: LatLng(
                    double.parse(location['latitude'].toString()),
                    double.parse(location['longitude'].toString()),
                  ),
                  type: 'task',
                  state: traducirEstadoTarea(location['state']),
                  skillsWithLevel: location['skills_with_level'],
                ),
              )
              .toList();
    } catch (e) {
      print('Error cargando tareas: $e');
    }
  }

  Future<void> _fetchMeetingPoints() async {
    try {
      final locations = await LocationServices.fetchMeetingPointLocations();

      _markers['meeting_point'] =
          locations
              .map(
                (location) => MapMarker(
                  id: location['id']?.toString() ?? '',
                  name: location['name'] ?? 'Sin nombre',
                  position: LatLng(
                    double.parse(location['latitude'].toString()),
                    double.parse(location['longitude'].toString()),
                  ),
                  type: 'meeting_point',
                ),
              )
              .toList();
    } catch (e) {
      print('Error cargando puntos de encuentro: $e');
    }
  }

  Future<void> _fetchPickupPoints() async {
    try {
      final locations = await LocationServices.fetchPickupPointLocations();

      _markers['pickup_point'] =
          locations
              .map(
                (location) => MapMarker(
                  id: location['id']?.toString() ?? '',
                  name: location['name'] ?? 'Sin nombre',
                  position: LatLng(
                    double.parse(location['latitude'].toString()),
                    double.parse(location['longitude'].toString()),
                  ),
                  type: 'pickup_point',
                  physicalDonation: location['quantity'] ?? 0,
                ),
              )
              .toList();
    } catch (e) {
      print('Error cargando puntos de recogida: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
