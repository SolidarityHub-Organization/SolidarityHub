import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/victim_marker_creator.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/volunteer_marker_creator.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/task_marker_creator.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/meeting_point_marker_creator.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/pickup_point_marker_creator.dart';

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
    case 'meeting_point':
      return MeetingPointMarkerCreator();
    case 'pickup_point':
      return PickupPointMarkerCreator();
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
