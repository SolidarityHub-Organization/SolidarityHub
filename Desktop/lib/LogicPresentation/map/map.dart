import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../LogicBusiness/services/victimServices.dart';
import '../../LogicBusiness/services/volunteerServices.dart';
import '../../LogicBusiness/services/task_services.dart';
import '../../LogicPersistence/models/mapMarker.dart';
import 'markerfactory.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MapViewMode { victim, volunteer, task, all }

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];
  MapViewMode _currentMode = MapViewMode.all;

  final VictimService _victimServices = VictimService('http://localhost:5170');
  final VolunteerService _volunteerServices = VolunteerService('http://localhost:5170');
  final TaskService _taskServices = TaskService('http://localhost:5170');
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchVictimLocations();
    _fetchVolunteerLocations();
    _fetchTaskLocations();
  }

  Future<void> _fetchVictimLocations() async {
    try {
      final locations = await _victimServices.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      //print(locations);
      setState(() {
        _markers.addAll(
            mapMarkers.map((mapMarker) {
              final markerCreator = getMarkerCreator(mapMarker.type);
              return markerCreator.createMarker(mapMarker, context);
            }).toList());
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las ubicaciones: $e')),
      );
      print('Error al obtener las ubicaciones: $e');
    }
  }

  Future<void> _fetchVolunteerLocations() async {
    try {
      final locations = await _volunteerServices.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      //print(locations);
      setState(() {
        _markers.addAll(
            mapMarkers.map((mapMarker) {
              final markerCreator = getMarkerCreator(mapMarker.type);
              return markerCreator.createMarker(mapMarker, context);
            }).toList());
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las ubicaciones: $e')),
      );
      print('Error al obtener las ubicaciones: $e');
    }
  }

  Future<void> _fetchTaskLocations() async {
    try {
      final locations = await _taskServices.fetchLocations();

      List<MapMarker> mapMarkers =
          locations.map((location) {
            return MapMarker.fromJson(location);
          }).toList();

      //print(locations);
      setState(() {
        _markers.addAll(
            mapMarkers.map((mapMarker) {
              final markerCreator = getMarkerCreator(mapMarker.type);
              return markerCreator.createMarker(mapMarker, context);
            }).toList());
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las ubicaciones: $e')),
      );
      print('Error al obtener las ubicaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: "Se desarrollará en el Sprint 2",
                  child: ElevatedButton(
                    onPressed: () {}, // Botón habilitado (sin funcionalidad)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Botón 1",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Tooltip(
                  message: "Se desarrollará en el Sprint 2",
                  child: ElevatedButton(
                    onPressed: () {}, // Botón habilitado (sin funcionalidad)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Botón 2",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(39.47391, -0.37966),
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: ['a', 'b', 'c', 'd'],
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                final zoom = _mapController.zoom + 1;
                                _mapController.move(
                                  _mapController.center,
                                  zoom,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                final zoom = _mapController.zoom - 1;
                                _mapController.move(
                                  _mapController.center,
                                  zoom,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _markers.clear();
                                  switch (_currentMode) {
                                    case MapViewMode.victim:
                                      _currentMode = MapViewMode.volunteer;
                                      _fetchVolunteerLocations();
                                      break;
                                    case MapViewMode.volunteer:
                                      _currentMode = MapViewMode.task;
                                      _fetchTaskLocations();
                                      break;
                                    case MapViewMode.task:
                                      _currentMode = MapViewMode.all;
                                      _fetchVictimLocations();
                                      _fetchVolunteerLocations();
                                      _fetchTaskLocations();
                                      break;
                                    case MapViewMode.all:
                                      _currentMode = MapViewMode.victim;
                                      _fetchVictimLocations();
                                      break;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text(
                                "⇆",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
