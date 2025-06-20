import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../decorator/info_square_decorator.dart';
import '../../../services/location_services.dart';
import 'package:latlong2/latlong.dart';
import '../../../controllers/map/map_screen_controller.dart';

class AffectedZoneInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    // Define theme colors for affected zones
    final Color primaryColor = Colors.red;
    final Color secondaryColor = primaryColor.withOpacity(0.7);
    
    // Create rows of information - without coordinates
    List<InfoRowData> rows = [
      // Add zone name as first row
      InfoRowData(
        icon: Icons.place, 
        label: 'Nombre', 
        value: mapMarker.name ?? 'Zona sin nombre'
      ),
      InfoRowData(
        icon: Icons.warning_amber, 
        label: 'Nivel de riesgo', 
        value: _translateHazardLevel(mapMarker.urgencyLevel)
      ),
      InfoRowData(
        icon: Icons.description, 
        label: 'Descripción', 
        value: mapMarker.state ?? 'Sin descripción'
      ),
    ];
    
    // Use the decorator with fixed title
    InfoSquare emptySquare = EmptyInfoSquare();
    InfoSquare decoratedSquare = CompleteStyleDecorator.create(
      emptySquare,
      title: 'Detalles de la zona afectada',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      mainIcon: Icons.warning_amber,
      rows: rows,
    );
    
    return decoratedSquare.buildInfoSquare(mapMarker);
  }
  
  String _translateHazardLevel(String? hazardLevel) {
    switch (hazardLevel?.toLowerCase()) {
      case 'high':
      case '3':
        return 'Alto';
      case 'medium':
      case '2':
        return 'Medio';
      case 'low':
      case '1':
        return 'Bajo';
      default:
        return 'Desconocido';
    }
  }
}

// If you don't already have this class from volunteer_info_square.dart
class EmptyInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container();
  }
}