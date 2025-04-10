import 'package:latlong2/latlong.dart';

class UserLocation {
  final int id;
  final String name;
  final LatLng position;
  final String role;

  UserLocation({
    required this.id,
    required this.name,
    required this.position,
    required this.role,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      position: LatLng(json['latitude'] as double, json['longitude'] as double),
      role: json['role'] as String,
    );
  }
}
