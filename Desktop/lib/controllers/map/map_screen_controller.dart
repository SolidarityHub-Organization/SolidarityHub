import 'dart:math' as math;
import 'dart:async';
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
  // Add these new variables for drawing
  bool _isDrawingMode = false;
  List<LatLng> _currentDrawingPoints = [];
  List<List<LatLng>> _drawnPolygons = [];
  String _selectedHazardLevel = 'medium'; // default hazard level

  // For tracking timestamps of drawn points
  List<DateTime> _pointTimestamps = [];
  
  // Mock functionality properties
  List<String> _mockMessages = [];
  List<Map<String, dynamic>> _mockZones = [];

  // Add these fields to your controller class
  bool _showSuccessAnimation = false;
  Timer? _successAnimationTimer;
  double _animationOpacity = 1.0;

  // Add this property
  LatLng? _previewPoint;

  // Add near the other boolean flags
  bool _isDeleteZoneMode = false;

  // Add these properties to your controller
  bool _isZoneButtonExpanded = false;
  bool get isZoneButtonExpanded => _isZoneButtonExpanded;

  // Getters
  Set<MapViewMode> get selectedModes => _selectedModes;
  IMapComponent? get selectedMarker => _selectedMarker;
  bool get isHeatMapActive => _isHeatMapActive;
  void set isHeatMapActive(bool value) {
    if (_isHeatMapActive != value) {
      _isHeatMapActive = value;
      notifyListeners();
    }
  }
  bool get isRouteMapActive => _isRouteMapActive;
  double get currentZoom => _currentZoom;
  List<MapPolygon> get polygons => _polygons;
  LatLng? get routeStart => _routeStart;
  LatLng? get routeEnd => _routeEnd;
  List<LatLng> get routePoints => _routePoints;
  TypeofRoute? get selectedRouteType => _selectedRouteType;
  double? get routeDistance => _routeDistance;
  double? get routeDuration => _routeDuration;
  RouteResult? get routeResult => _routeResult;  // Make sure these getters are properly exposing the state
  bool get isDrawingMode => _isDrawingMode;
  bool get showSuccessAnimation => _showSuccessAnimation;
  double get animationOpacity => _animationOpacity;
  List<LatLng> get currentDrawingPoints => _currentDrawingPoints;
  List<List<LatLng>> get drawnPolygons => _drawnPolygons;
  String get selectedHazardLevel => _selectedHazardLevel;
  List<String> get mockMessages => _mockMessages;
  List<Map<String, dynamic>> get mockZones => _mockZones;
  LatLng? get previewPoint => _previewPoint; // Add a getter
  bool get isDeleteZoneMode => _isDeleteZoneMode; // Add to getters

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
    final List<Map<String, dynamic>> zones = await AffectedZoneServices.fetchAffectedZones();
    
    // Set the affectedZones property for use in other places
    affectedZones = zones;
    
    // Convertir las zonas afectadas a polígonos para el mapa
    _polygons = _convertAffectedZonesToPolygons(zones);

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

// Helper method to compare two LatLng points for equality
bool _pointsAreEqual(LatLng a, LatLng b) {
  return a.latitude == b.latitude && a.longitude == b.longitude;
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
  // Toggle drawing mode
  void toggleDrawingMode(BuildContext context) {
    _isDrawingMode = !_isDrawingMode;
    if (_isDrawingMode) {
      _currentDrawingPoints.clear();
    } else {
      _currentDrawingPoints.clear();
    }
    notifyListeners();
  }

  // Set hazard level
  void setHazardLevel(String level) {
    _selectedHazardLevel = level;
    notifyListeners();
  }
  // Handle tap when in drawing mode (legacy, consider removing if not needed)
    void handleDrawingTap(LatLng point, BuildContext context) {
      if (_isDrawingMode) {
        // Check for intersections
        if (_currentDrawingPoints.isNotEmpty && _wouldCreateSelfIntersection(point)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La línea no puede cruzarse con otra línea existente'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      
        _currentDrawingPoints.add(point);
        notifyListeners();
      }
    }

    // Check if adding a new point would create ANY self-intersection in the polygon
    bool _wouldCreateSelfIntersection(LatLng newPoint) {
      print("\n---- CHECKING FOR INTERSECTIONS ----");
      print("New point: ${newPoint.latitude}, ${newPoint.longitude}");
      print("Total existing points: ${_currentDrawingPoints.length}");
      
      // We need at least 2 points to check for intersections
      if (_currentDrawingPoints.length < 2) {
        print("Not enough points to check for intersections");
        return false;
      }
      
      LatLng lastPoint = _currentDrawingPoints.last;
      LatLng firstPoint = _currentDrawingPoints.first;
      
      // Print all existing segments
      print("\nEXISTING SEGMENTS:");
      for (int i = 0; i < _currentDrawingPoints.length - 1; i++) {
        print("Segment $i: point[$i] to point[${i+1}]");
      }
      
      int lastSegmentIndex = _currentDrawingPoints.length - 2;
      print("\nLast segment index: $lastSegmentIndex");
      
      // CHECK 1: Line from last point to new point
      print("\nCHECK 1: Line from last point to new point");
      for (int i = 0; i < _currentDrawingPoints.length - 1; i++) {
        // Skip ONLY the last segment (which ends at lastPoint - they share an endpoint)
        if (i == lastSegmentIndex) {
          print("Skipping segment $i (it ends at the last point - shared endpoint)");
          continue;
        }
        
        LatLng segStart = _currentDrawingPoints[i];
        LatLng segEnd = _currentDrawingPoints[i + 1];
        
        bool intersects = _lineSegmentsIntersect(lastPoint, newPoint, segStart, segEnd);
        print("Check new line against segment $i: " + (intersects ? "INTERSECTS ⚠️" : "clear"));
        
        if (intersects) {
          print("INTERSECTION FOUND: New line crosses segment $i");
          return true;
        }
      }
      
      // CHECK 2: Line from new point to first point (closing segment)
      print("\nCHECK 2: Line from new point to first point (closing segment)");
      for (int i = 0; i < _currentDrawingPoints.length - 1; i++) {
        // For the closing segment (newPoint → firstPoint), we only skip:
        // - Segment 0: because it STARTS from firstPoint (shared endpoint with closing line)
        // - We do NOT skip the last segment because the closing line doesn't share any endpoints with it
    
        if (i == 0) {
          print("Skipping segment $i (starts from first point - shared endpoint with closing line)");
          continue;
        }
        
        // DO NOT SKIP THE LAST SEGMENT - it should be checked!
        LatLng segStart = _currentDrawingPoints[i];
        LatLng segEnd = _currentDrawingPoints[i + 1];
        
        bool intersects = _lineSegmentsIntersect(newPoint, firstPoint, segStart, segEnd);
        print("Check closing line against segment $i: " + (intersects ? "INTERSECTS ⚠️" : "clear"));
        
        if (intersects) {
          print("INTERSECTION FOUND: Closing line crosses segment $i");
          return true;
        }
      }
      
      print("\nNO INTERSECTIONS DETECTED ✓");
      return false;
    }

    // Finish drawing and save polygon
  Future<void> finishDrawing(BuildContext context) async {
    if (_currentDrawingPoints.length >= 3) {
      // Show dialog to get zone details
      await _showZoneDetailsDialog(context);
    }
  }

  // Show dialog to get zone details
  Future<void> _showZoneDetailsDialog(BuildContext context) async {
    String zoneName = '';
    String zoneDescription = '';
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Zona Afectada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre de la zona',
                  hintText: 'Ej: Zona inundada centro',
                ),
                onChanged: (value) => zoneName = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe el tipo de afectación',
                ),
                maxLines: 3,
                onChanged: (value) => zoneDescription = value,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedHazardLevel,
                decoration: InputDecoration(labelText: 'Nivel de peligro'),
                items: [
                  DropdownMenuItem(value: 'low', child: Text('Bajo')),
                  DropdownMenuItem(value: 'medium', child: Text('Medio')),
                  DropdownMenuItem(value: 'high', child: Text('Alto')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedHazardLevel = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelDrawing();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (zoneName.isNotEmpty) {
                  await _saveAffectedZone(context, zoneName, zoneDescription);
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
  // Mock save affected zone (doesn't save to database)
  Future<void> _saveAffectedZone(BuildContext context, String name, String description) async {
    try {
      // Create zone data
      Map<String, dynamic> zoneData = {
        'name': name,
        'description': description,
        'hazard_level': _selectedHazardLevel, // String values "Low", "Medium", etc.
        'admin_id': 1,
      };

      // Create points data
      List<Map<String, dynamic>> points = _currentDrawingPoints.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList();

      // Call the API service to create the zone with locations
      bool success = await LocationServices.createZoneWithLocations(zoneData, points);

      if (success) {
        print("Zone created successfully, starting animation"); // Debug print
        
        // Start animation - MAKE SURE THIS IS CALLED
        _startSuccessAnimation();
        _isDrawingMode = false;
        
        // Refresh to show the newly created zone
        if (_isHeatMapActive) {
          _generateHeatMap();
        }
        
        notifyListeners();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la zona afectada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating affected zone: $e');
    }
  }

  // Convert string hazard levels to integers
  int getHazardLevelValue(String level) {
    switch(level) {
      case 'low': return 1;
      case 'medium': return 2;
      case 'high': return 3;
      default: return 1;
    }
  }

  // Add mock message to the list
  void _addMockMessage(String message, {bool isSuccess = true}) {
    String timestamp = DateTime.now().toString().substring(11, 19); // HH:MM:SS
    String formattedMessage = '[$timestamp] $message';
    _mockMessages.add(formattedMessage);
    
    // Keep only the last 10 messages
    if (_mockMessages.length > 10) {
      _mockMessages.removeAt(0);
    }
    
    notifyListeners();
  }

  // Clear all mock messages
  void clearMockMessages() {
    _mockMessages.clear();
    notifyListeners();
  }

  // Clear all mock zones
  void clearMockZones() {
    _mockZones.clear();
    _drawnPolygons.clear();
    notifyListeners();
  }

  // Cancel current drawing
  void _cancelDrawing() {
    _currentDrawingPoints.clear();
    _isDrawingMode = false;
    notifyListeners();
  }

  // Undo last point
  void undoLastPoint(BuildContext context) {
    if (_currentDrawingPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay puntos para deshacer')),
      );
      return;
    }
    
    _currentDrawingPoints.removeLast();
    notifyListeners();
  }

  @override
  void dispose() {
    _successAnimationTimer?.cancel();
    super.dispose();
  }

  // Refresh affected zones data
  Future<void> refreshAffectedZones() async {
    if (_isHeatMapActive) {
      await _generateHeatMap();
    }
  }

  // Animation control methods
void _startSuccessAnimation() {
  _showSuccessAnimation = true;
  _animationOpacity = 1.0;
  
  // Start with an immediate refresh of the heatmap
  _generateHeatMap();
  
  notifyListeners();
  
  // Cancel any existing timer
  _successAnimationTimer?.cancel();
  
  // Use a faster animation (10 steps over 0.8 seconds = 80ms per step)
  final totalSteps = 10;
  final fadeTime = 800; // 0.8 seconds
  final stepTime = fadeTime ~/ totalSteps;
  int currentStep = 0;
  
  _successAnimationTimer = Timer.periodic(Duration(milliseconds: stepTime), (timer) {
    currentStep++;
    // Calculate opacity based on remaining steps (smooth fade out)
    _animationOpacity = 1.0 - (currentStep / totalSteps);
    notifyListeners();
    
    if (currentStep >= totalSteps) {
      // When fully transparent, clean up
      _successAnimationTimer?.cancel();
      _successAnimationTimer = null;
      _showSuccessAnimation = false;
      _currentDrawingPoints = [];
      notifyListeners();
    }
  });
}

// Add this new animation method near _startSuccessAnimation
void _startDeleteAnimation(List<LatLng> zonePoints) {
  // Store the polygons to animate
  selectedZonePolygon = zonePoints;
  _showDeleteAnimation = true;
  _animationOpacity = 1.0;
  
  // Start with an immediate refresh of the heatmap data in the background
  // This ensures the data is updated even if animation fails
  _generateHeatMap();
  
  notifyListeners();
  
  // Cancel any existing timer
  _deleteAnimationTimer?.cancel();
  
  // Use a faster animation (10 steps over 0.8 seconds = 80ms per step)
  final totalSteps = 10;
  final fadeTime = 800; // 0.8 seconds
  final stepTime = fadeTime ~/ totalSteps;
  int currentStep = 0;
  
  _deleteAnimationTimer = Timer.periodic(Duration(milliseconds: stepTime), (timer) {
    currentStep++;
    // Calculate opacity based on remaining steps (smooth fade out)
    _animationOpacity = 1.0 - (currentStep / totalSteps);
    notifyListeners();
    
    if (currentStep >= totalSteps) {
      // When fully transparent, clean up
      _deleteAnimationTimer?.cancel();
      _deleteAnimationTimer = null;
      _showDeleteAnimation = false;
      selectedZonePolygon = null;
      notifyListeners();
    }
  });
}

// Add these properties near the other animation properties
bool _showDeleteAnimation = false;
Timer? _deleteAnimationTimer;

// Add these getters
bool get showDeleteAnimation => _showDeleteAnimation;

  // More accurate line segment intersection detection
bool _lineSegmentsIntersect(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
  // Skip if endpoints are the same (connected segments)
  if ((p1.latitude == p3.latitude && p1.longitude == p3.longitude) ||
      (p1.latitude == p4.latitude && p1.longitude == p4.longitude) ||
      (p2.latitude == p3.latitude && p2.longitude == p3.longitude) ||
      (p2.latitude == p4.latitude && p2.longitude == p4.longitude)) {
    return false;
  }
  
  // Direction vectors
  double d1x = p2.longitude - p1.longitude;
  double d1y = p2.latitude - p1.latitude;
  double d2x = p4.longitude - p3.longitude;
  double d2y = p4.latitude - p3.latitude;
  
  // Calculate determinant
  double det = d1x * d2y - d1y * d2x;
  
  // If determinant is zero, lines are parallel
  if (det.abs() < 1e-10) return false;
  
  // Calculate parameters of intersection
  double dx = p3.longitude - p1.longitude;
  double dy = p3.latitude - p1.latitude;
  
  double t = (dx * d2y - dy * d2x) / det;
  double s = (dx * d1y - dy * d1x) / det;
  
  // Check if intersection is within both line segments
  return (t > 0 && t < 1 && s > 0 && s < 1);
}

// Delete an affected zone by ID
Future<bool> deleteAffectedZone(int zoneId, BuildContext context, {List<LatLng>? zonePoints}) async {
  try {
    print("Deleting zone $zoneId"); // Debug print
    
    // Call the service to delete the zone
    bool success = await LocationServices.deleteZoneWithLocations(zoneId);
    print("Delete success: $success"); // Debug print
    
    if (success) {
      // 1. Clear selected marker first
      clearSelectedMarker();
      
      // 2. Start delete animation if we have the zone points
      if (zonePoints != null && zonePoints.isNotEmpty) {
        _startDeleteAnimation(zonePoints);
      } else {
        // If no points provided, just refresh the heatmap
        await _generateHeatMap();
      }
      return true;
    }
    return false;
  } catch (e) {
    print('Error deleting zone: $e');
    return false;
  }
}

// Get all affected zones with details for management
Future<List<Map<String, dynamic>>> getAllAffectedZones() async {
  try {
    return await AffectedZoneServices.fetchAffectedZones();
  } catch (e) {
    print('Error fetching affected zones: $e');
    return [];
  }
}

// Show dialog to manage (view/delete) affected zones
Future<void> showZoneManagementDialog(BuildContext context) async {
  List<Map<String, dynamic>> zones = await getAllAffectedZones();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Gestionar Zonas Afectadas'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: zones.isEmpty 
                ? Center(child: Text('No hay zonas afectadas'))
                : ListView.builder(
                    itemCount: zones.length,
                    itemBuilder: (context, index) {
                      final zone = zones[index];
                      final hazardLevel = zone['hazard_level']?.toString() ?? 'unknown';
                      
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getHazardColor(hazardLevel),
                            child: Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          title: Text(zone['name'] ?? 'Sin nombre'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(zone['description'] ?? 'Sin descripción'),
                              Text(
                                'Nivel: ${_translateHazardLevel(hazardLevel)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getHazardColor(hazardLevel),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Confirm deletion
                              bool confirm = await _showDeleteConfirmation(
                                context, 
                                zone['name'] ?? 'esta zona'
                              );
                              
                              if (confirm) {
                                bool deleted = await deleteAffectedZone(
                                  zone['id'], 
                                  context
                                );
                                

                                if (deleted) {
                                  // Remove from local list and refresh dialog
                                  setState(() {
                                    zones.removeAt(index);
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    },
  );
}

// Show confirmation dialog for deletion
Future<bool> _showDeleteConfirmation(BuildContext context, String zoneName) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar "$zoneName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      );
    },
  ) ?? false;
}

// Helper method to get hazard level color
Color _getHazardColor(String hazardLevel) {
  switch (hazardLevel.toLowerCase()) {
    case 'high':
    case 'alto':
    case '3':
      return Colors.red;
    case 'medium':
    case 'medio':
    case '2':
      return Colors.orange;
    case 'low':
    case 'bajo':
    case '1':
      return Colors.yellow;
    default:
      return Colors.grey;
  }
}

// Helper method to translate hazard level
String _translateHazardLevel(String hazardLevel) {
  switch (hazardLevel.toLowerCase()) {
    case 'high':
    case '3':
      return 'Alto';
    case 'medium':
    case '2':
      return 'Medio';
    case 'low':
    case '1':
      return 'Bajo';
    default:
      return 'Desconocido';
  }
}

List<LatLng>? selectedZonePolygon;

void selectZonePolygon(List<LatLng> polygon) {
  selectedZonePolygon = polygon;
  notifyListeners();
}

void clearSelectedZonePolygon() {
  selectedZonePolygon = null;
  notifyListeners();
}

Future<void> regenerateHeatMap() async {
  await _generateHeatMap();
}

List<Map<String, dynamic>> affectedZones = [];

// Add this method
void toggleZoneMode(BuildContext context) {
  // If we were in delete mode, exit it
  if (_isDeleteZoneMode) {
    _isDeleteZoneMode = false;
    _isDrawingMode = false;
    clearSelectedZonePolygon();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modo normal activado'))
    );
  }
  // If we were in draw mode, switch to delete mode
  else if (_isDrawingMode) {
    _isDrawingMode = false;
    _isDeleteZoneMode = true;
    _currentDrawingPoints.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modo eliminar zona activado. Toca una zona para eliminarla.'))
    );
  }
  // If we were in normal mode, switch to draw mode
  else {
    _isDrawingMode = true;
    _isDeleteZoneMode = false;
    _currentDrawingPoints.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modo dibujar zona activado. Toca el mapa para añadir puntos.'))
    );
  }
  notifyListeners();
}

// Add this method to handle clicks on zones for deletion
Future<void> handleZoneClick(int zoneId, String zoneName, BuildContext context, {List<LatLng>? zonePoints}) async {
  if (!_isDeleteZoneMode) return;
  
  // Show confirmation dialog
  bool confirmed = await _showDeleteConfirmation(context, zoneName);
  
  if (confirmed) {
    bool success = await deleteAffectedZone(zoneId, context, zonePoints: zonePoints);
    
    if (success) {
      // No snackbar needed since we have a visual animation
      clearSelectedZonePolygon();
      // Stay in delete mode so user can delete more zones if needed
    }
  }
}

// Add these methods to your controller
void toggleZoneButtonExpanded() {
  _isZoneButtonExpanded = !_isZoneButtonExpanded;
  notifyListeners();
}

void startDrawingMode() {
  _isDrawingMode = true;
  _isDeleteZoneMode = false;
  _currentDrawingPoints.clear();
  notifyListeners();
}

void startDeleteMode() {
  _isDeleteZoneMode = true;
  _isDrawingMode = false;
  _currentDrawingPoints.clear();
  notifyListeners();
}

void cancelDrawing() {
  _isDrawingMode = false;
  _currentDrawingPoints.clear();
  notifyListeners();
}

void cancelDeleteMode() {
  _isDeleteZoneMode = false;
  notifyListeners();
}

void cancelAllZoneModes() {
  _isDrawingMode = false;
  _isDeleteZoneMode = false;
  _isZoneButtonExpanded = false;
  _currentDrawingPoints.clear();
  notifyListeners();
}
}