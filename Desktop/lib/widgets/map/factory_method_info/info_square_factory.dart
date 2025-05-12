import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'victim_info_square.dart';
import 'volunteer_info_square.dart';
import 'task_info_square.dart';
import 'meeting_point_info_square.dart';
import 'pickup_point_info_square.dart';

abstract class InfoSquare {
  Widget buildInfoSquare(MapMarker mapMarker);
}

InfoSquare getInfoSquare(String role) {
  switch (role) {
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
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
