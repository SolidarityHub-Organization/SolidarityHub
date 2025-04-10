import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
      position: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      role: json['role'] as String, 
    );
  }
}

abstract class MapMarkerCreator {
  Marker createMarker(UserLocation user, BuildContext context);
}

class VictimMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(UserLocation user, BuildContext context) {
    return Marker(
      point: user.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
        },
        child: const Icon(Icons.location_pin, color: Color.fromARGB(255, 43, 210, 252), size: 40),
      ),
    );
  }
}

class VolunteerMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(UserLocation user, BuildContext context) {
    return Marker(
      point: user.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          
        },
        child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
      ),
    );
  }
}

MapMarkerCreator getMarkerCreator(String role) {
  switch (role) {
    case 'victim':
      return VictimMarkerCreator();
    case 'volunteer':
      return VolunteerMarkerCreator();
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}