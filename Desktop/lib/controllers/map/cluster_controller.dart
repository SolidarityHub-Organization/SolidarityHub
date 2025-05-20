import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/models/mapMarkerCluster.dart';

class ClusterController {
  static const double _ZOOM_THRESHOLD = 11.0;
  static const double _EARTH_RADIUS = 6378137.0;
  static const double _PIXEL_REFERENCE_ZOOM20 = 0.15;

  // FUNCIONES PRINCIPALES PÚBLICAS

  /// Crea clusters de marcadores basados en su proximidad geográfica
  static List<MapMarker> createClusters(List<MapMarker> markers, double zoom, bool clusteringEnabled) {
    if (!clusteringEnabled || zoom >= _ZOOM_THRESHOLD) {
      return markers;
    }

    // Primero agrupamos por tipo
    Map<String, List<MapMarker>> markersByType = {};
    for (var marker in markers) {
      if (!markersByType.containsKey(marker.type)) {
        markersByType[marker.type] = [];
      }
      markersByType[marker.type]!.add(marker);
    }

    // Luego aplicamos clustering a cada grupo por separado
    List<MapMarker> result = [];
    markersByType.forEach((type, typeMarkers) {
      final double baseDistance = _getBaseDistanceForZoom(zoom);
      result.addAll(_groupMarkersIntoClusters(typeMarkers, zoom, baseDistance));
    });

    return result;
  }

  /// Crea un marcador visual para representar un cluster en el mapa
  static Marker createClusterMarker(
    MapMarker clusterMarker,
    Function(MapMarker) onClusterTapped,
    double currentZoom,
    Function(LatLng, double) moveMap,
    Color Function(String) getClusterColor,
  ) {
    return Marker(
      point: clusterMarker.position,
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: _buildClusterWidget(clusterMarker, currentZoom, moveMap, getClusterColor),
    );
  }

  /// Calcula la distancia entre dos posiciones geográficas considerando el zoom
  static double calculateDistance(LatLng pos1, LatLng pos2, double zoom) {
    double latFactor = _EARTH_RADIUS * 2 * pi / 360;
    double lonFactor = _EARTH_RADIUS * 2 * pi / 360 * cos(pi * (pos1.latitude / 180));

    double dy = (pos2.latitude - pos1.latitude) * latFactor;
    double dx = (pos2.longitude - pos1.longitude) * lonFactor;
    double distanceInMeters = sqrt(dx * dx + dy * dy);

    return distanceInMeters / (_PIXEL_REFERENCE_ZOOM20 * pow(2, 20 - zoom));
  }

  // MÉTODOS PARA CREACIÓN DE CLUSTERS

  /// Determina la distancia base para agrupar según el nivel de zoom
  static double _getBaseDistanceForZoom(double zoom) {
    if (zoom < 10) return 60.0;
    if (zoom < 12) return 40.0;
    return 20.0;
  }

  /// Agrupa marcadores en clusters según la distancia entre ellos
  static List<MapMarker> _groupMarkersIntoClusters(List<MapMarker> markers, double zoom, double baseDistance) {
    List<MapMarker> processedMarkers = [];
    List<MapMarker> resultMarkers = [];

    for (var marker in markers) {
      if (processedMarkers.contains(marker)) continue;

      // Buscamos solo marcadores del mismo tipo que el actual
      List<MapMarker> cluster = _findNearbyMarkers(marker, markers, processedMarkers, zoom, baseDistance);

      if (cluster.length > 1) {
        resultMarkers.add(_createClusterMarker(cluster, resultMarkers.length));
      } else {
        resultMarkers.add(marker);
      }
    }

    return resultMarkers;
  }

  /// Encuentra marcadores cercanos a un marcador base
  static List<MapMarker> _findNearbyMarkers(
    MapMarker baseMarker,
    List<MapMarker> allMarkers,
    List<MapMarker> processedMarkers,
    double zoom,
    double baseDistance,
  ) {
    List<MapMarker> cluster = [baseMarker];
    processedMarkers.add(baseMarker);

    for (var otherMarker in allMarkers) {
      if (baseMarker != otherMarker && !processedMarkers.contains(otherMarker) && baseMarker.type == otherMarker.type) {
        // Solo juntamos del mismo tipo
        double distance = calculateDistance(baseMarker.position, otherMarker.position, zoom);

        if (distance <= baseDistance) {
          cluster.add(otherMarker);
          processedMarkers.add(otherMarker);
        }
      }
    }

    return cluster;
  }

  /// Crea un marcador de cluster a partir de una lista de marcadores
  static MapMarker _createClusterMarker(List<MapMarker> cluster, int index) {
    LatLng clusterCenter = MapMarkerCluster.calculateClusterCenter(cluster);
    // Aseguramos que el tipo del cluster sea el mismo que el de sus elementos
    String clusterType = cluster[0].type;
    return MapMarkerCluster.createCluster(
      id: 'cluster_$index',
      position: clusterCenter,
      count: cluster.length,
      items: cluster,
      type: clusterType, // Conservamos el tipo para identificación del cluster
    );
  }

  // MÉTODOS DE UI PARA VISUALIZACIÓN DE CLUSTERS

  /// Construye el widget visual del cluster
  static Widget _buildClusterWidget(
    MapMarker clusterMarker,
    double currentZoom,
    Function(LatLng, double) moveMap,
    Color Function(String) getClusterColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Al hacer clic, simplemente hacemos zoom en la posición del cluster
        double zoomIncrement = 2.0;
        moveMap(clusterMarker.position, currentZoom + zoomIncrement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: getClusterColor(clusterMarker.type),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: Text(
            '${clusterMarker.clusterCount}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
