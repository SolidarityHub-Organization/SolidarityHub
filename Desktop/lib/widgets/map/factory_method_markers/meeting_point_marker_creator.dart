import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/widgets/map/factory_method_markers/marker_factory.dart';

class MeetingPointMarkerCreator implements MapMarkerCreator {
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
            border: Border.all(color: Colors.green, width: 2), // Color verde para donaciones
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(0), // Forma de pin igual que los otros marcadores
            )
          ),
          child: Center(
            child: Icon(
              Icons.group, // Icono de donación/regalo
              color: Colors.green,
              size: 20,
            ),
          )
        ) 
      ),
    );
  }
}
