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
    return Row(
      children: [        // Contenedor principal del mapa que se ajusta cuando se abre el panel
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
                    )
                  : Container(), // Contenedor vacío cuando no hay marcador seleccionado
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
                  if (controller.isRouteMapActive) {
                    // Si el mapa de rutas está activo, generamos la ruta
                    controller.generateRouteMap(tapPosition, point, context);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                // Convertimos los polígonos de nuestro modelo a polígonos de flutter_map
                PolygonLayer(
                  polygons:
                      controller.isHeatMapActive
                          ? controller.polygons
                              .map(
                                (poly) => Polygon(
                                  points: poly.points,
                                  color: poly.color,
                                  borderColor: poly.borderColor,
                                  borderStrokeWidth: poly.borderStrokeWidth,
                                  isFilled: true,
                                ),
                              )
                              .toList()
                          : [],
                ),

                PolylineLayer(
                  polylines:
                      controller.isRouteMapActive
                          ? [Polyline(points: controller.routePoints, strokeWidth: 5.0, color: Colors.blue)]
                          : [],
                ),
                MarkerLayer(markers: [...flutterMapMarkers, ...specialRouteMarkers]),
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
          ],
        ),
      ),
    );
  }
}
