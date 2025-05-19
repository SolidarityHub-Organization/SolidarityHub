import 'package:latlong2/latlong.dart';


class MapMarker {
  final String id;
  final String name;
  final LatLng position;
  final String type;
  final String? urgencyLevel;
  final String? state;
  final dynamic time;
  final dynamic physicalDonation;
  final bool isCluster;
  final int? clusterCount;
  final List<MapMarker>? clusterItems;
  final Map<String, dynamic>? skillsWithLevel;

  MapMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    this.urgencyLevel,
    this.state,
    this.time,
    this.physicalDonation,
    this.isCluster = false,
    this.clusterCount,
    this.clusterItems,
    this.skillsWithLevel,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    print('JSON recibido en MapMarker.fromJson: $json');
    return MapMarker(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      position: LatLng(double.parse(json['latitude'].toString()), double.parse(json['longitude'].toString())),
      type: json['type']?.toString() ?? '',
      urgencyLevel: json['urgencyLevel']?.toString(),
      state: json['state']?.toString(),
      time: json['time'],
      physicalDonation: json['physical_donation'],
      skillsWithLevel: json['skills_with_level'],
    );
  }

  @override
  String toString() {
    return 'MapMarker(id: $id, name: $name, type: $type, urgencyLevel: $urgencyLevel, state: $state, position: $position, time: $time, physicalDonation: $physicalDonation, isCluster: $isCluster, clusterCount: $clusterCount)';
  }
}