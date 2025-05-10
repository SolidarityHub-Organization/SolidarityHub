import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'victim_info_square.dart';
import 'volunteer_info_square.dart';
import 'task_info_square.dart';

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
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
