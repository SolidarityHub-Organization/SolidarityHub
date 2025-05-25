import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorator/info_square_decorator.dart';

class PickupPointInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    final donations = mapMarker.physicalDonation is List ? mapMarker.physicalDonation as List : null;

    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        final Color primaryColor = Color.fromARGB(255, 30, 136, 229);
        final Color secondaryColor = Color.fromARGB(255, 100, 181, 246);

        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.location_pin, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
        ];

        if (mapMarker.time != null) {
          String formattedTime = mapMarker.time is String ? mapMarker.time as String : mapMarker.time.toString();
          rows.add(InfoRowData(icon: Icons.access_time, label: 'Horario', value: formattedTime));
        }

        if (donations != null && donations.isNotEmpty) {
          int totalQuantity = 0;
          for (var donation in donations) {
            if (donation is Map && donation.containsKey('quantity')) {
              var quantity = donation['quantity'];
              if (quantity is int) {
                totalQuantity += quantity;
              } else if (quantity != null) {
                totalQuantity += int.tryParse(quantity.toString()) ?? 0;
              }
            }
          }
          rows.add(
            InfoRowData(
              icon: Icons.card_giftcard,
              label: 'Tipos de donaciones',
              value: '${donations.length} (${totalQuantity} unidades)',
            ),
          );
        } else if (mapMarker.physicalDonation is int && mapMarker.physicalDonation != null) {
          rows.add(
            InfoRowData(icon: Icons.card_giftcard, label: 'Total donaciones', value: '${mapMarker.physicalDonation}'),
          );
        }

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
