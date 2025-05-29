import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorator/info_square_decorator.dart';

class VolunteerInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para voluntarios
        final Color primaryColor = Color.fromARGB(255, 255, 79, 135);
        final Color secondaryColor = Color.fromARGB(255, 255, 143, 180); // Crear las filas de información
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.person_pin, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
          InfoRowData(
            icon: Icons.gps_fixed,
            label: 'Coordenadas',
            value:
                '${mapMarker.position.latitude.toStringAsFixed(6)}, ${mapMarker.position.longitude.toStringAsFixed(6)}',
          ),
        ];

        // Usar el decorador completo
        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: 'Detalles del voluntario',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.volunteer_activism,
          rows: rows,
        );

        return decoratedSquare.buildInfoSquare(mapMarker);
      },
    );
  }
}

// Base vacía para iniciar la cadena de decoración
class EmptyInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container();
  }
}
