import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/marker_factory.dart';

class MeetingPointMarkerCreator implements MapMarkerCreator {
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