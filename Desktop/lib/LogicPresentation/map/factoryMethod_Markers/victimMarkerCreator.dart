import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/LogicPresentation/map/factoryMethod_Markers/markerFactory.dart';

class VictimMarkerCreator implements MapMarkerCreator {
  Color _getColorByUrgency(String? urgencyLevel) {
    if (urgencyLevel == null || urgencyLevel.isEmpty) {
      return Colors.grey;
    }

    String level = urgencyLevel.toLowerCase().trim();

    if (level == 'unknown' || level == 'desconocido') {
      return Colors.grey;
    } else if (level == 'low' || level == 'bajo') {
      return Colors.green;
    } else if (level == 'medium' || level == 'medio') {
      return Colors.orange;
    } else if (level == 'high' || level == 'alto') {
      return const Color.fromARGB(255, 255, 0, 0);
    } else if (level == 'critical' || level == 'crítico') {
      return const Color.fromARGB(255, 139, 0, 0);
    } else {
      return Colors.grey;
    }
  }

  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    try {
      String? effectiveUrgencyLevel = mapMarker.urgencyLevel;
      if (effectiveUrgencyLevel == null || effectiveUrgencyLevel.isEmpty) {
        effectiveUrgencyLevel = 'Unknown';
      }

      final markerColor = _getColorByUrgency(effectiveUrgencyLevel);

      return Marker(
        point: mapMarker.position,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            onMarkerTap(mapMarker);
          },
          child: Icon(Icons.location_pin, color: markerColor, size: 40),
        ),
      );
    } catch (e) {
      return Marker(
        point: mapMarker.position,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            onMarkerTap(mapMarker);
          },
          child: Icon(Icons.location_pin, color: Colors.grey, size: 40),
        ),
      );
    }
  }
}
