import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorador/info_square_decorator.dart';

class MeetingPointInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para puntos de encuentro
        final Color primaryColor = Color.fromARGB(255, 56, 142, 60);
        final Color secondaryColor = Color.fromARGB(255, 129, 199, 132);

        // Crear las filas de información
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.location_pin, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
        ];

        // Agregar horario si existe
        if (mapMarker.time != null) {
          rows.add(InfoRowData(icon: Icons.access_time, label: 'Horario', value: mapMarker.time.toString()));
        }

        // Usar el decorador completo
        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: 'Detalles del punto de encuentro',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.group,
          rows: rows,
        );

        return decoratedSquare.buildInfoSquare(mapMarker);
      },
    );
  }
}
