import 'package:latlong2/latlong.dart';

class MapMarker {
  final int id;
  final String name;
  final LatLng position;
  final String type;

  MapMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      id: json['id'] as int,
      name: json['name'] as String,
      position: LatLng(json['latitude'] as double, json['longitude'] as double),
      type: json['type'] as String,
    );
  }
}
