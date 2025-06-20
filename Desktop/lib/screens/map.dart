import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/controllers/map/map_screen_controller.dart';
import 'package:solidarityhub/controllers/map/cluster_controller.dart';
import 'package:solidarityhub/widgets/map/filterButton.dart';
import 'package:solidarityhub/widgets/map/legends.dart';
import 'package:solidarityhub/widgets/map/searchBar.dart';
import 'package:solidarityhub/widgets/map/infoPanel.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/marker_factory.dart';
import 'package:solidarityhub/models/imap_component.dart';
import 'package:solidarityhub/models/mapMarkerCluster.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/drawing_controls.dart';

class MapScreen extends StatefulWidget {
  final double? lat;
  final double? lng;
  final double? initialZoom;

  const MapScreen({Key? key, this.lat, this.lng, this.initialZoom}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final MapScreenController _screenController = MapScreenController();
  final TextEditingController _searchController = TextEditingController();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Configurar listener para actualizar la UI cuando cambie el controlador
    _screenController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Cargar datos inmediatamente
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _screenController.fetchAllData();
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _screenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cálculo del ancho del panel basado en el tamaño de la pantalla
    final double infoPanelWidth = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isDataLoaded ? _buildResponsiveLayout(context, infoPanelWidth) : Center(child: CircularProgressIndicator()),
    );
  }
  Widget _buildResponsiveLayout(BuildContext context, double infoPanelWidth) {
    return Column(
      children: [
        // Main map area
        Expanded(
          child: Row(
            children: [              // Contenedor principal del mapa que se ajusta cuando se abre el panel
              Expanded(child: _buildMapWithOverlays(context, _screenController)),

              // Panel de información con animación
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _screenController.selectedMarker != null ? infoPanelWidth : 0,
                curve: Curves.easeInOut,
                child:
                    _screenController.selectedMarker != null
                        ? MapInfoPanel(
                            component: _screenController.selectedMarker!,
                            onClose: () => _screenController.clearSelectedMarker(),
                          )                        : Container(), // Contenedor vacío cuando no hay marcador seleccionado
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapWithOverlays(BuildContext context, MapScreenController controller) {
    // Now get a list of IMapComponent, not just MapMarker
    List<IMapComponent> processedMarkers = controller.getFilteredAndProcessedMarkers();

    // Generate markers for the map
    List<Marker> flutterMapMarkers = processedMarkers.map((marker) {
      if (marker is MapMarkerCluster) {
        return ClusterController.createClusterMarker(
          marker,
          (cluster) {
            // Show info panel for cluster
            controller.selectMarker(cluster);
          },
          controller.currentZoom,
          (position, zoom) {/* No zoom on click */},
          controller.getClusterColor,
        );
      } else if (marker is MapMarker) {
        final creator = getMarkerCreator(marker.type);
        return creator.createMarker(marker, context, (m) => controller.selectMarker(m));
      } else {
        // Should not happen, but fallback
        return Marker(
          point: marker.position,
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: Colors.grey),
        );
      }
    }).toList();

    List<Marker> specialRouteMarkers = [];
    if (controller.routeStart != null) {
      specialRouteMarkers.add(
        Marker(
          point: controller.routeStart!,
          width: 40,
          height: 40,
          child: Icon(Icons.flag, color: Colors.green, size: 36),
        ),
      );
    }
    if (controller.routeEnd != null) {
      specialRouteMarkers.add(
        Marker(
          point: controller.routeEnd!,
          width: 40,
          height: 40,
          child: Icon(Icons.flag, color: Colors.red, size: 36),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            // El mapa base
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
                  if (widget.lat != null && widget.lng != null) {
                    _mapController.move(LatLng(widget.lat!, widget.lng!), widget.initialZoom ?? 15.0);
                  }
                },
                onPositionChanged: (position, hasGesture) {
                  if (position.zoom != null) {
                    controller.updateZoom(position.zoom!);
                  }
                },
                onTap: (tapPosition, point) {
                  // First priority: Check which interaction mode we're in
                  if (controller.isDeleteZoneMode) {
                    // Look for a zone that contains the tapped point for deletion
                    for (final zone in controller.affectedZones) {
                      final polygon = (zone['points'] as List)
                          .map((p) => p is LatLng ? p : LatLng(p['latitude'] ?? p['lat'], p['longitude'] ?? p['lng']))
                          .toList();
                      
                      if (_isPointInPolygon(point, polygon)) {
                        // Found a zone to delete - handle it
                        controller.handleZoneClick(
                          zone['id'],
                          zone['name'] ?? 'Zona sin nombre',
                          context,
                          zonePoints: polygon
                        );
                        return; // Exit early after finding a match
                      }
                    }
                  }
                  else if (controller.isDrawingMode) {
                    controller.handleDrawingTap(point, context);
                    return;
                  }
                  else if (controller.isRouteMapActive) {
                    controller.generateRouteMap(tapPosition, point, context);
                    return;
                  }
                  
                  // Second priority: Check for taps in existing polygons (if not in a special mode)
                  if (controller.isHeatMapActive || controller.drawnPolygons.isNotEmpty) {
                    // Check if tap is inside any affected zone polygon
                    for (final zone in controller.affectedZones) {
                      final polygon = (zone['points'] as List)
                          .map((p) => p is LatLng ? p : LatLng(p['latitude'] ?? p['lat'], p['longitude'] ?? p['lng']))
                          .toList();
                      
                      if (_isPointInPolygon(point, polygon)) {
                        // Create a MapMarker for this zone and show info panel
                        final mapMarker = MapMarker(
                          id: zone['id'].toString(),
                          name: zone['name'] ?? 'Zona Afectada',
                          position: point,
                          type: 'affected_zone',
                          urgencyLevel: (zone['hazard_level'] ?? 'medium').toString(),
                          state: zone['description'] ?? 'Sin descripción',
                        );
                        
                        // Show the info panel
                        controller.selectMarker(mapMarker);
                        return;
                      }
                    }
                  }
                  
                  // Last priority: Default tap behavior (clear selection)
                  if (controller.selectedMarker != null) {
                    controller.clearSelectedMarker();
                  }
                },
                onLongPress: (tapPosition, point) {
                  if (controller.isDrawingMode && controller.currentDrawingPoints.length >= 3) {
                    controller.finishDrawing(context);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                
                // Existing heat map polygon layer
                PolygonLayer(
                  polygons: controller.isHeatMapActive
                      ? controller.polygons.map((polygon) {
                          // Create the polygon without onTap
                          return Polygon(
                            points: polygon.points,
                            color: polygon.color,
                            borderStrokeWidth: polygon.borderStrokeWidth,
                            borderColor: polygon.borderColor,
                            isFilled: true,
                            // Remove the onTap parameter - it's not supported
                          );
                        }).toList()
                      : [],
                ),                // NEW: Drawing overlay polygon
                if (controller.isDrawingMode)
                  PolygonLayer(
                    polygons: [
                      if (controller.currentDrawingPoints.length >= 2)
                        Polygon(
                          points: controller.currentDrawingPoints,
                          color: _getHazardColor(controller.selectedHazardLevel).withOpacity(0.3),
                          borderColor: _getHazardColor(controller.selectedHazardLevel),
                          borderStrokeWidth: 2,
                          isDotted: true,
                        ),
                    ],
                  ),

                // NEW: Mock drawn polygons layer (persistent)
                PolygonLayer(
                  polygons: controller.drawnPolygons.map((drawnPolygon) {
                    return Polygon(
                      points: drawnPolygon,
                      color: Colors.purple.withOpacity(0.4), // Mock zones are purple
                      borderColor: Colors.purple,
                      borderStrokeWidth: 2,
                      isFilled: true,
                    );
                  }).toList(),
                ),

                // Existing route polyline
                PolylineLayer(
                  polylines: controller.isRouteMapActive
                      ? [Polyline(points: controller.routePoints, strokeWidth: 5.0, color: Colors.blue)]
                      : [],
                ),
                
                // Existing markers
                MarkerLayer(markers: [...flutterMapMarkers, ...specialRouteMarkers]),
                
                // NEW: Drawing points markers
                if (controller.isDrawingMode)
                  MarkerLayer(
                    markers: controller.currentDrawingPoints.asMap().entries.map((entry) {
                      return Marker(
                        point: entry.value,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                // NEW: Drawing success/failure polygon
                if (controller.currentDrawingPoints.isNotEmpty) 
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: controller.currentDrawingPoints,
                        color: controller.showSuccessAnimation 
                            ? Colors.green.withOpacity(controller.animationOpacity * 0.5) 
                            : Colors.purple.withOpacity(0.4),
                        borderColor: controller.showSuccessAnimation
                            ? Colors.green.withOpacity(controller.animationOpacity)
                            : Colors.purple,
                        borderStrokeWidth: controller.showSuccessAnimation ? 4.0 : 2.0,
                        isFilled: true,
                      ),
                    ],
                  ),
              ],
            ),
            // Barra de búsqueda
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: MapSearchBar(
                controller: _searchController,
                onSearch: (value) async {
                  final result = await controller.searchAddress(value);
                  if (result != null) {
                    final location = result['location'] as LatLng;
                    final zoomLevel = result['zoomLevel'] as double;
                    _mapController.move(location, zoomLevel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dirección no encontrada')));
                  }
                },
                onClear: () => _searchController.clear(),
              ),
            ),
            // Botones de filtro
            Positioned(
              top: 82,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MapFilterButton(
                    label: 'Afectados',
                    isSelected: controller.selectedModes.contains(MapViewMode.victim),
                    onPressed: () => controller.toggleViewMode(MapViewMode.victim),
                    icon: Icons.people,
                    color: Colors.red,
                  ),
                  SizedBox(height: 8),
                  MapFilterButton(
                    label: 'Voluntarios',
                    isSelected: controller.selectedModes.contains(MapViewMode.volunteer),
                    onPressed: () => controller.toggleViewMode(MapViewMode.volunteer),
                    icon: Icons.volunteer_activism,
                    color: Color.fromARGB(255, 255, 79, 135),
                  ),
                  SizedBox(height: 8),
                  MapFilterButton(
                    label: 'Tareas',
                    isSelected: controller.selectedModes.contains(MapViewMode.task),
                    onPressed: () => controller.toggleViewMode(MapViewMode.task),
                    icon: Icons.task,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 8),
                  MapFilterButton(
                    label: 'Puntos de Encuentro',
                    isSelected: controller.selectedModes.contains(MapViewMode.meeting_point),
                    onPressed: () => controller.toggleViewMode(MapViewMode.meeting_point),
                    icon: Icons.group,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  MapFilterButton(
                    label: 'Puntos de Recogida',
                    isSelected: controller.selectedModes.contains(MapViewMode.pickup_point),
                    onPressed: () => controller.toggleViewMode(MapViewMode.pickup_point),
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),

            // Botón de mapa de calor
            Positioned(
              bottom: 16,
              left: 16,
              child: MapFilterButton(
                label: 'Mapa de Calor',
                isSelected: controller.isHeatMapActive,
                onPressed: () => controller.toggleHeatMap(),
                icon: Icons.heat_pump,
                color: Colors.red,
              ),
            ),
            // Botón de mapa de rutas
            Positioned(
              bottom: 16,
              left: 180,
              child: MapFilterButton(
                label: 'Mapa de rutas',
                isSelected: controller.isRouteMapActive,
                onPressed: () => controller.toggleRouteMap(context),
                icon: Icons.alt_route,
                color: Colors.red,
              ),
            ),
            //Boton para elegir el tipo de ruta
            if (controller.isRouteMapActive)
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: DropdownButton<TypeofRoute>(
                    value: controller.selectedRouteType,
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down),
                    items: [
                      DropdownMenuItem(
                        value: TypeofRoute.car,
                        child: Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Coche'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: TypeofRoute.bike,
                        child: Row(
                          children: [
                            Icon(Icons.directions_bike, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Bicicleta'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: TypeofRoute.walking,
                        child: Row(
                          children: [
                            Icon(Icons.directions_walk, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Andando'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (type) {
                      if (type != null) {
                        controller.setRouteType(type);
                      }
                    },
                  ),
                ),
              ),
            // Leyendas condicionales
            if (controller.isHeatMapActive) Positioned(bottom: 70, left: 16, child: HeatMapLegend()),

            if (controller.selectedModes.contains(MapViewMode.victim))
              Positioned(bottom: 16, right: 16, child: UrgencyLegend()),

            if (controller.selectedModes.contains(MapViewMode.task))
              Positioned(
                bottom: controller.selectedModes.contains(MapViewMode.victim) ? 250 : 16,
                right: 16,
                child: TaskLegend(),
              ),
            // Drawing controls
            if (controller.isDrawingMode)
              Positioned(
                top: 90,
                right: 16,
                child: DrawingControls(
                  onToggleDrawing: () => controller.toggleDrawingMode(context),
                  onUndoPoint: () => controller.undoLastPoint(context),
                  onFinishDrawing: () => controller.finishDrawing(context),
                  isDrawingMode: controller.isDrawingMode,
                  currentPointsCount: controller.currentDrawingPoints.length,
                  selectedHazardLevel: controller.selectedHazardLevel,
                  onHazardLevelChanged: (level) => controller.setHazardLevel(level),
                ),
              ),

            // Replace the existing button with this expandable button group
            Positioned(
              bottom: 16,
              left: 344,
              child: _buildExpandableZoneControls(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableZoneControls(MapScreenController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Draw Zone Button - Only visible when expanded or in drawing mode
        if (controller.isDrawingMode || controller.isZoneButtonExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: 8),
            child: MapFilterButton(
              label: controller.isDrawingMode ? 'Cancelar Dibujo' : 'Dibujar Zona',
              isSelected: controller.isDrawingMode,
              onPressed: () {
                if (controller.isDrawingMode) {
                  controller.cancelDrawing();
                } else {
                  controller.startDrawingMode();
                  controller.toggleZoneButtonExpanded();
                }
              },
              icon: controller.isDrawingMode ? Icons.close : Icons.draw,
              color: Colors.orange,
            ),
          ),
        
        // Delete Zone Button - Only visible when expanded in delete mode
        if (controller.isDeleteZoneMode || controller.isZoneButtonExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: 8),
            child: MapFilterButton(
              label: controller.isDeleteZoneMode ? 'Cancelar Eliminación' : 'Eliminar Zona',
              isSelected: controller.isDeleteZoneMode,
              onPressed: () {
                if (controller.isDeleteZoneMode) {
                  controller.cancelDeleteMode();
                } else {
                  controller.startDeleteMode();
                  controller.toggleZoneButtonExpanded();
                }
              },
              icon: controller.isDeleteZoneMode ? Icons.close : Icons.delete,
              color: Colors.red,
            ),
          ),
        
        // Main toggle button
        MapFilterButton(
          label: 'Zonas',
          isSelected: controller.isZoneButtonExpanded,
          onPressed: () {
            // Only toggle expansion if we're not already in a mode
            if (!controller.isDrawingMode && !controller.isDeleteZoneMode) {
              controller.toggleZoneButtonExpanded();
            } else {
              // If in a mode, cancel it
              controller.cancelAllZoneModes();
            }
          },
          icon: controller.isZoneButtonExpanded ? Icons.close : Icons.edit_location_alt,
          color: Colors.purple,
        ),
      ],
    );
  }

  // Helper method for hazard colors
  Color _getHazardColor(String hazardLevel) {
    switch (hazardLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // Check if a point is inside a polygon using ray-casting algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    // Ray-casting algorithm to determine if point is in polygon
    bool isInside = false;
    int i = 0, j = polygon.length - 1;
    
    for (i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * 
          (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) + 
          polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    
    return isInside;
  }

  // Add this helper function to compare polygons
  bool _polygonsEqual(List<LatLng> poly1, List<LatLng> poly2) {
    if (poly1.length != poly2.length) return false;
    
    // Compare a few points to see if they match (exact match isn't necessary)
    const tolerance = 0.0001; // Adjust based on your precision needs
    
    // Check first, middle, and last points
    final checkPoints = [0, poly1.length ~/ 2, poly1.length - 1];
    
    for (final idx in checkPoints) {
      final p1 = poly1[idx];
      final p2 = poly2[idx];
      
      if ((p1.latitude - p2.latitude).abs() > tolerance ||
          (p1.longitude - p2.longitude).abs() > tolerance) {
        return false;
      }
    }
    
    return true;
  }
}
