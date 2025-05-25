import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'victim_marker_creator.dart';
import 'task_marker_creator.dart';
import 'volunteer_marker_creator.dart';
import 'meeting_point_marker_creator.dart';
import 'pickup_point_marker_creator.dart';

// Interfaz base para todos los creadores de marcadores
abstract class MapMarkerCreator {
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap);
}

// Función Factory Method para obtener el creador adecuado según el tipo
MapMarkerCreator getMarkerCreator(String type) {
  switch (type.toLowerCase()) {
    case 'victim':
      return VictimMarkerCreator();
    case 'volunteer':
      return VolunteerMarkerCreator();
    case 'task':
      return TaskMarkerCreator();
    case 'meeting_point':
      return MeetingPointMarkerCreator();
    case 'pickup_point':
      return PickupPointMarkerCreator();
    default:
      // Si el tipo no es reconocido, usamos el marcador de víctima como predeterminado
      return VictimMarkerCreator();
  }
}
