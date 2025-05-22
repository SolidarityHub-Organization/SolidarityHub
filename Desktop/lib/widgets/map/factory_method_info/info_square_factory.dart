import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import '../decorador/info_square_decorator.dart';
import 'victim_info_square.dart';
import 'volunteer_info_square.dart';
import 'task_info_square.dart';
import 'meeting_point_info_square.dart';
import 'pickup_point_info_square.dart';

abstract class InfoSquare {
  Widget buildInfoSquare(MapMarker mapMarker);
}

/// Método factory para obtener el InfoSquare apropiado según el rol
InfoSquare getInfoSquare(String role) {
  late InfoSquare base;
  switch (role) {
    case 'victim':
      base = VictimInfoSquare();
      break;
    case 'volunteer':
      base = VolunteerInfoSquare();
      break;
    case 'task':
      base = TaskInfoSquare();
      break;
    case 'meeting_point':
      base = MeetingPointInfoSquare();
      break;
    case 'pickup_point':
      base = PickupPointInfoSquare();
      break;
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }

  // Ahora aplicamos el decorador
  return BorderInfoSquareDecorator(base);
}

/// Un InfoSquare vacío para iniciar la cadena de decoración
class EmptyInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container();
  }
}
