import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/LogicPresentation/map/factoryMethod_Markers/victimMarkerCreator.dart';
import 'package:solidarityhub/LogicPresentation/map/factoryMethod_Markers/volunteerMarkerCreator.dart';
import 'package:solidarityhub/LogicPresentation/map/factoryMethod_Markers/taskMarkerCreator.dart';

abstract class MapMarkerCreator {
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap);
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
