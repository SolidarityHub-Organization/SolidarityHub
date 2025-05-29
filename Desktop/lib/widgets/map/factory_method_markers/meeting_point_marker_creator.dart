import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/marker_factory.dart';

class MeetingPointMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    return Marker(
      point: mapMarker.position,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(mapMarker);
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child: Icon(Icons.group, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
