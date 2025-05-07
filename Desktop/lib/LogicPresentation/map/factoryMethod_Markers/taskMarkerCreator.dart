import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/LogicPresentation/map/factoryMethod_Markers/markerFactory.dart';

class TaskMarkerCreator implements MapMarkerCreator {
  IconData _getIconByState(String? state) {
    if (state == null) return Icons.assignment_outlined;

    // Asegurarse de que el valor sea una cadena
    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Icons.assignment_turned_in_rounded;
      case 'asignado':
        return Icons.assignment_outlined;
      case 'pendiente':
        return Icons.assignment_return_rounded;
      case 'cancelado':
        return Icons.assignment_late_outlined;
    }

    // Este punto solo se alcanza para propósitos de compilación
    return Icons.assignment_outlined;
  }

  // Método para determinar el color según el estado
  Color _getColorByState(String? state) {
    if (state == null) return Colors.orange;

    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'pendiente':
        return Colors.blue;
      case 'asignado':
        return Colors.orange;
    }

    return Colors.orange;
  }

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
        child: Icon(_getIconByState(mapMarker.state), color: _getColorByState(mapMarker.state), size: 40),
      ),
    );
  }
}
