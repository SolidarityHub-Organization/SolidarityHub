import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'victim_info_square.dart';
import 'volunteer_info_square.dart';
import 'task_info_square.dart';
import 'meeting_point_info_square.dart';
import 'pickup_point_info_square.dart';
import 'affected_zone_info_square.dart';

// Interfaz base para todos los cuadros de información
abstract class InfoSquare {
  Widget buildInfoSquare(MapMarker mapMarker);
}

// Clase que implementa el patrón Factory Method para crear InfoSquares
class InfoSquareFactory {
  static InfoSquare createInfoSquare(String type) {
    switch (type.toLowerCase()) {
      case 'victim':
        return VictimInfoSquare();
      case 'volunteer':
        return VolunteerInfoSquare();
      case 'task':
        return TaskInfoSquare();
      case 'meeting_point':
        return MeetingPointInfoSquare();
      case 'pickup_point':
        return PickupPointInfoSquare();
      case 'affected_zone':
        return AffectedZoneInfoSquare();
      default:
        return EmptyInfoSquare();
    }
  }
}

// Clase base vacía para usar en decoradores
class EmptyInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container();
  }
}
