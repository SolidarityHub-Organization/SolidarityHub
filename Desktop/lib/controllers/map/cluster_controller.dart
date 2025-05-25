import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/models/mapMarkerCluster.dart';

class ClusterController {
  // Crea un marcador para un cluster en el mapa
  static Marker createClusterMarker(
    MapMarker cluster,
    Function(MapMarker) onTap,
    double currentZoom,
    Function(LatLng, double) onZoomTo,
    Function(List<MapMarker>) getClusterColor,
  ) {
    final items = cluster.clusterItems ?? [];
    final color = getClusterColor(items);

    // Ajustar el tamaño del cluster según la cantidad de elementos
    double size = 80.0;
    double fontSize = 16.0;

    // Si es un cluster grande, hacerlo más notable
    if (cluster.clusterCount != null && cluster.clusterCount! > 20) {
      size = 90.0;
      fontSize = 18.0;
    }

    // Si es el cluster global (único), destacarlo más
    if (cluster.id == 'main-cluster') {
      size = 100.0;
      fontSize = 20.0;
    }

    return Marker(
      width: size,
      height: size,
      point: cluster.position,
      child: GestureDetector(
        onTap: () {
          // Solo mostrar información del cluster, sin hacer zoom
          onTap(cluster);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1))],
          ),
          child: Center(
            child: Text(
              '${cluster.clusterCount}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }

  // Algoritmo para agrupar marcadores en clusters
  static List<MapMarker> clusterMarkers(List<MapMarker> markers) {
    if (markers.isEmpty) return [];

    // Ahora incluimos todos los marcadores para el clustering, incluyendo los pickup_points
    final List<MapMarker> clusterableMarkers = List.from(markers);

    // Si hay solo un marcador, lo retornamos directamente
    if (clusterableMarkers.length == 1) return clusterableMarkers;

    // Opciones de clustering:
    // 1. Si hay pocos marcadores, creamos clusters por proximidad (como antes)
    // 2. Si hay muchos marcadores o estamos muy alejados, creamos un único cluster global

    // Para un único cluster global
    if (clusterableMarkers.length > 5) {
      // Crear un único cluster global con todos los marcadores
      final clusterId = 'main-cluster';
      final clusterCenter = MapMarkerCluster.calculateClusterCenter(clusterableMarkers);

      // Determinar el tipo predominante en el cluster
      Map<String, int> typeCounts = {};
      for (var item in clusterableMarkers) {
        typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
      }

      String dominantType = 'victim'; // Por defecto
      int maxCount = 0;
      typeCounts.forEach((type, count) {
        if (count > maxCount) {
          maxCount = count;
          dominantType = type;
        }
      });

      // Crear y devolver un único cluster
      return [
        MapMarkerCluster.createCluster(
          id: clusterId,
          position: clusterCenter,
          count: clusterableMarkers.length,
          items: clusterableMarkers,
          type: dominantType,
        ),
      ];
    } else {
      // Si hay pocos marcadores, aplicamos clustering por proximidad
      final clusterDistance = 0.01; // Aproximadamente 1km
      final List<MapMarker> result = [];
      final List<bool> processed = List.filled(clusterableMarkers.length, false);

      for (int i = 0; i < clusterableMarkers.length; i++) {
        if (processed[i]) continue;
        processed[i] = true;
        final currentMarker = clusterableMarkers[i];

        // Si el marcador ya es un cluster, lo agregamos directamente
        if (currentMarker.isCluster) {
          result.add(currentMarker);
          continue;
        }

        List<MapMarker> clusterItems = [currentMarker];

        // Buscar marcadores cercanos
        for (int j = 0; j < clusterableMarkers.length; j++) {
          if (i == j || processed[j]) continue;

          final otherMarker = clusterableMarkers[j];
          final distance = _calculateDistance(
            currentMarker.position.latitude,
            currentMarker.position.longitude,
            otherMarker.position.latitude,
            otherMarker.position.longitude,
          );

          if (distance <= clusterDistance) {
            clusterItems.add(otherMarker);
            processed[j] = true;
          }
        }

        // Si solo hay un marcador, lo agregamos directamente
        if (clusterItems.length == 1) {
          result.add(currentMarker);
        } else {
          // Crear un cluster
          final clusterId = 'cluster-${result.length}';
          final clusterCenter = MapMarkerCluster.calculateClusterCenter(clusterItems);

          // Determinar el tipo predominante en el cluster
          Map<String, int> typeCounts = {};
          for (var item in clusterItems) {
            typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
          }

          String dominantType = 'victim'; // Por defecto
          int maxCount = 0;
          typeCounts.forEach((type, count) {
            if (count > maxCount) {
              maxCount = count;
              dominantType = type;
            }
          });

          result.add(
            MapMarkerCluster.createCluster(
              id: clusterId,
              position: clusterCenter,
              count: clusterItems.length,
              items: clusterItems,
              type: dominantType,
            ),
          );
        }
      }
      return result;
    }
  }

  // Cálculo simplificado de distancia usando la fórmula de Haversine
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // en kilómetros
    final double latDiff = _degreesToRadians(lat2 - lat1);
    final double lonDiff = _degreesToRadians(lon2 - lon1);

    final double a =
        (sin(latDiff / 2) * sin(latDiff / 2)) +
        (cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(lonDiff / 2) * sin(lonDiff / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    // Convertimos a grados aproximados para facilitar la comparación
    return distance / 111; // 111 km ~ 1 grado
  }

  // Convertir grados a radianes
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
