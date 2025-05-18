import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/mapMarker.dart';

class MapMarkerCluster {
  static MapMarker createCluster({
    required String id,
    required LatLng position,
    required int count,
    required List<MapMarker> items,
  }) {
    // Determinar el tipo predominante en el cluster
    String dominantType = 'victim'; // Valor por defecto
    if (items.isNotEmpty) {
      Map<String, int> typeCounts = {};
      for (var item in items) {
        if (typeCounts.containsKey(item.type)) {
          typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
        } else {
          typeCounts[item.type] = 1;
        }
      }

      // Encontrar el tipo más común
      int maxCount = 0;
      for (var entry in typeCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          dominantType = entry.key;
        }
      }
    }

    return MapMarker(
      id: id,
      name: 'Cluster de $count elementos',
      position: position,
      type: dominantType,
      isCluster: true,
      clusterCount: count,
      clusterItems: items,
    );
  }

  // Método para calcular el centro de un cluster
  static LatLng calculateClusterCenter(List<MapMarker> markers) {
    double sumLat = 0;
    double sumLng = 0;

    for (var marker in markers) {
      sumLat += marker.position.latitude;
      sumLng += marker.position.longitude;
    }

    return LatLng(sumLat / markers.length, sumLng / markers.length);
  }
}
