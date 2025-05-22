import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorador/info_square_decorator.dart';

class VictimInfoSquare implements InfoSquare {
  // Método para obtener el color según el nivel de urgencia
  Color _getUrgencyColor(String? urgencyLevel) {
    if (urgencyLevel == null) return Colors.grey;

    String level = urgencyLevel.toLowerCase().trim();

    if (level.contains('low') || level.contains('bajo')) {
      return Colors.green;
    } else if (level.contains('medium') || level.contains('medio')) {
      return Colors.orange;
    } else if (level.contains('high') || level.contains('alto')) {
      return Colors.red;
    } else if (level.contains('critical') || level.contains('crítico')) {
      return Colors.red.shade900;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para víctimas
        final Color primaryColor = Colors.red.shade700;
        final Color secondaryColor = Colors.red.shade300;

        // Crear las filas de información con textos que se puedan ajustar
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.person_pin, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
          InfoRowData(
            icon: Icons.priority_high,
            label: 'Nivel de urgencia',
            value: mapMarker.urgencyLevel ?? 'Desconocido',
            valueColor: _getUrgencyColor(mapMarker.urgencyLevel),
          ),
        ];

        // Obtenemos el tamaño de la pantalla para adaptar el diseño
        final screenWidth = MediaQuery.of(context).size.width;

        // Ajustar el diseño si la pantalla es muy pequeña
        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: screenWidth < 400 ? 'Afectado' : 'Detalles del afectado',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.person,
          rows: rows,
        );

        return Container(
          // Limitamos el ancho máximo para evitar expansión excesiva
          constraints: BoxConstraints(
            maxWidth: 500,
            // Altura flexible con mínimo para evitar que se haga demasiado pequeño
            minHeight: 300,
          ),
          child: decoratedSquare.buildInfoSquare(mapMarker),
        );
      },
    );
  }
}
