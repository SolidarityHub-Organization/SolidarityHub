import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorador/info_square_decorator.dart';

class PickupPointInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    final donations = mapMarker.physicalDonation is List ? mapMarker.physicalDonation as List : null;

    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para puntos de recogida
        final Color primaryColor = Color.fromARGB(255, 30, 136, 229);
        final Color secondaryColor = Color.fromARGB(255, 100, 181, 246);

        // Crear las filas de información
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.location_pin, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
        ];

        // Agregar horario si existe
        if (mapMarker.time != null) {
          rows.add(InfoRowData(icon: Icons.access_time, label: 'Horario', value: mapMarker.time.toString()));
        }

        // Agregar donaciones si existen
        if (donations != null && donations.isNotEmpty) {
          rows.add(InfoRowData(icon: Icons.card_giftcard, label: 'Donaciones', value: '${donations.length}'));
        }

        // Usar el decorador completo
        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: 'Detalles del punto de recogida',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.local_shipping,
          rows: rows,
        );

        return decoratedSquare.buildInfoSquare(mapMarker);
      },
    );
  }
}
