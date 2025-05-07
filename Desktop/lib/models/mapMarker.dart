import 'package:latlong2/latlong.dart';

class MapMarker {
  final String id;
  final String name;
  final LatLng position;
  final String type;
  final String? urgencyLevel;
  final String? state;

  MapMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    this.urgencyLevel,
    this.state,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    // Asegurarse de que los valores se conviertan correctamente a String
    return MapMarker(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      position: LatLng(double.parse(json['latitude'].toString()), double.parse(json['longitude'].toString())),
      type: json['type']?.toString() ?? '',
      urgencyLevel: json['urgencyLevel']?.toString(),
      state: json['state']?.toString(),
    );
  }

  @override
  String toString() {
    return 'MapMarker(id: $id, name: $name, type: $type, urgencyLevel: $urgencyLevel, state: $state, position: $position)';
  }
}
