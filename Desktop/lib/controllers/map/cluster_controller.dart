import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/imap_component.dart';
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
  static List<IMapComponent> clusterMarkers(
    List<IMapComponent> components,
    double currentZoom,
    {
    double markerClusterDistance = 0.01,
    double clusterClusterDistance = 0.02,
    int maxLevels = 2,
  }) {
    if (components.isEmpty) return [];

    // start with all components (markers and clusters)
    List<IMapComponent> clustered = components;

    // at each level, cluster markers and clusters together
    for (int level = 0; level < maxLevels; level++) {
      final distance = (level == 0) ? markerClusterDistance : clusterClusterDistance;
      clustered = _proximityCluster(clustered, distance);

      // if only one cluster remains, stop early
      if (clustered.length <= 1) break;
    }

    return clustered;
  }

  // method treats clusters and markers identically for design pattern
  static List<IMapComponent> _proximityCluster(List<IMapComponent> items, double distanceThreshold) {
    final List<IMapComponent> result = [];
    final List<bool> processed = List.filled(items.length, false);

    for (int i = 0; i < items.length; i++) {
      if (processed[i]) continue;
      processed[i] = true;
      final current = items[i];

      List<IMapComponent> clusterItems = [current];

      for (int j = 0; j < items.length; j++) {
        if (i == j || processed[j]) continue;
        final other = items[j];
        final distance = _calculateDistance(
          current.position.latitude,
          current.position.longitude,
          other.position.latitude,
          other.position.longitude,
        );
        if (distance <= distanceThreshold) {
          clusterItems.add(other);
          processed[j] = true;
        }
      }

      if (clusterItems.length == 1) {
        result.add(current);
      } else {
        // before creating a new cluster, check if there's only one cluster
        // and everything else is single markers
        // in that case add items to the existing cluster rather than creating a new one

        MapMarkerCluster? existingCluster;
        int clusterCount = 0;
        
        for (var item in clusterItems) {
          if (item is MapMarkerCluster) {
            existingCluster = item;
            clusterCount++;
          }
        }
        
        // if there's  one cluster among the items, expand it
        if (clusterCount == 1 && existingCluster != null) {
          // add all non-cluster to the existing cluster
          List<IMapComponent> newChildren = [...existingCluster.getChildren()];
          for (var item in clusterItems) {
            if (item != existingCluster) {
              newChildren.add(item);
            }
          }
          
          result.add(MapMarkerCluster(
            id: existingCluster.id,
            name: existingCluster.name,
            position: MapMarkerCluster.calculateClusterCenter(newChildren),
            type: existingCluster.type,
            children: newChildren,
          ));
        } else {
          // create new cluster
          final clusterId = 'cluster-${result.length}';
          final clusterCenter = MapMarkerCluster.calculateClusterCenter(clusterItems);

          // determine dominant type
          Map<String, int> typeCounts = {};
          for (var item in clusterItems) {
            typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
          }
          String dominantType = 'victim';
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
    }
    return result;
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
