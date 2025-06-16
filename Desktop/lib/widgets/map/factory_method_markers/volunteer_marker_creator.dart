import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/marker_factory.dart';

class VolunteerMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(MapMarker mapMarker, BuildContext context, Function(MapMarker) onMarkerTap) {
    return Marker(
      point: mapMarker.position,
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(mapMarker);
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color.fromARGB(255, 255, 79, 135), width: 2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(0),
            )
          ),
          child: Center(
            child: Icon(
              Icons.volunteer_activism,
              color: Color.fromARGB(255, 255, 79, 135),
              size: 20,
            ),
          )
        ) 
      ),
    );
  }
}
