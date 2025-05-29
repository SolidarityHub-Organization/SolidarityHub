import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/imap_component.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/models/mapMarkerCluster.dart';

class ClusterController {
  // Crea un marcador para un cluster en el mapa
  static Marker createClusterMarker(
    MapMarkerCluster cluster,
    Function(IMapComponent) onTap,
    double currentZoom,
    Function(LatLng, double) onZoomTo,
    Function(List<IMapComponent>) getClusterColor,
  ) {
    final items = cluster.getChildren();
    final color = getClusterColor(items);

    // Ajustar el tamaño del cluster según la cantidad de elementos
    double size = 80.0;
    double fontSize = 16.0;

    // Si es un cluster grande, hacerlo más notable
    if (cluster.count > 20) {
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
              '${cluster.count}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }

  // Algoritmo para agrupar marcadores en clusters
  static List<IMapComponent> clusterMarkers(List<IMapComponent> components) {
    if (components.isEmpty) return [];

    // Incluimos todos los componentes para el clustering
    final List<IMapComponent> clusterableComponents = List.from(components);

    // Si hay solo un componente, lo retornamos directamente
    if (clusterableComponents.length == 1) return clusterableComponents;

    // Opciones de clustering:
    // 1. Si hay pocos componentes, creamos clusters por proximidad
    // 2. Si hay muchos componentes o estamos muy alejados, creamos un único cluster global

    // Para un único cluster global
    if (clusterableComponents.length > 5) {
      // Crear un único cluster global con todos los componentes
      final clusterId = 'main-cluster';
      final clusterCenter = MapMarkerCluster.calculateClusterCenter(clusterableComponents);

      // Determinar el tipo predominante en el cluster
      Map<String, int> typeCounts = {};
      for (var item in clusterableComponents) {
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
        MapMarkerCluster(
          id: clusterId,
          name: 'Cluster Principal',
          position: clusterCenter,
          type: dominantType,
          children: clusterableComponents,
        ),
      ];
    } else {
      // Si hay pocos componentes, aplicamos clustering por proximidad
      final clusterDistance = 0.01; // Aproximadamente 1km
      final List<IMapComponent> result = [];
      final List<bool> processed = List.filled(clusterableComponents.length, false);

      for (int i = 0; i < clusterableComponents.length; i++) {
        if (processed[i]) continue;
        processed[i] = true;
        final currentComponent = clusterableComponents[i];

        // Si el componente ya es un cluster, lo agregamos directamente
        if (currentComponent is MapMarkerCluster) {
          result.add(currentComponent);
          continue;
        }

        List<IMapComponent> clusterItems = [currentComponent];

        // Buscar componentes cercanos
        for (int j = 0; j < clusterableComponents.length; j++) {
          if (i == j || processed[j]) continue;

          final otherComponent = clusterableComponents[j];
          final distance = _calculateDistance(
            currentComponent.position.latitude,
            currentComponent.position.longitude,
            otherComponent.position.latitude,
            otherComponent.position.longitude,
          );

          if (distance <= clusterDistance) {
            clusterItems.add(otherComponent);
            processed[j] = true;
          }
        }

        // Si solo hay un componente, lo agregamos directamente
        if (clusterItems.length == 1) {
          result.add(currentComponent);
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
            MapMarkerCluster(
              id: clusterId,
              name: 'Cluster de marcadores',
              position: clusterCenter,
              type: dominantType,
              children: clusterItems,
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
