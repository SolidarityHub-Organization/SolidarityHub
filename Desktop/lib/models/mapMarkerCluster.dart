import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/models/mapMarker.dart';

class MapMarkerCluster {
  /// Calcula el centro geográfico para un grupo de marcadores
  static LatLng calculateClusterCenter(List<MapMarker> markers) {
    if (markers.isEmpty) {
      throw ArgumentError('No se pueden calcular coordenadas para una lista vacía de marcadores');
    }

    double totalLat = 0.0;
    double totalLng = 0.0;

    for (var marker in markers) {
      totalLat += marker.position.latitude;
      totalLng += marker.position.longitude;
    }

    return LatLng(totalLat / markers.length, totalLng / markers.length);
  }

  /// Crea un objeto MapMarker que representa un cluster
  static MapMarker createCluster({
    required String id,
    required LatLng position,
    required int count,
    required List<MapMarker> items,
    required String type, // Añadimos el tipo como parámetro obligatorio
  }) {
    return MapMarker(
      id: id,
      name: 'Cluster de $count elemento${count > 1 ? 's' : ''}',
      position: position,
      type: type, // Usamos el tipo proporcionado
      isCluster: true,
      clusterCount: count,
      clusterItems: items,
    );
  }
}
