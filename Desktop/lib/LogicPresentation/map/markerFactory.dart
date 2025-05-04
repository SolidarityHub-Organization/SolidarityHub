import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';

abstract class MapMarkerCreator {
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap);
}

class VictimMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    return Marker(
      point: mapMarker.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(mapMarker);
        },
        child: const Icon(Icons.location_pin, color: Color.fromARGB(255, 43, 210, 252), size: 40),
      ),
    );
  }
}

class VolunteerMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    return Marker(
      point: mapMarker.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(mapMarker);
        },
        child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
      ),
    );
  }
}

class TaskMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    return Marker(
      point: mapMarker.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(mapMarker);
        },
        child: const Icon(Icons.location_pin, color: Colors.orange, size: 40),
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
    case 'task':
      return TaskMarkerCreator();
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
