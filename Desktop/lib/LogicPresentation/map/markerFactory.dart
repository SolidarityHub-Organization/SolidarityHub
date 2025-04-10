import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../LogicPersistence/models/userLocation.dart';

abstract class MapMarkerCreator {
  Marker createMarker(UserLocation user, BuildContext context);
}

class VictimMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(UserLocation user, BuildContext context) {
    return Marker(
      point: user.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Detalles de la víctima'),
                  content: Text('ID: ${user.id}\nNombre: ${user.name}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
          );
        },
        child: const Icon(
          Icons.location_pin,
          color: Color.fromARGB(255, 43, 210, 252),
          size: 40,
        ),
      ),
    );
  }
}

class VolunteerMarkerCreator implements MapMarkerCreator {
  @override
  Marker createMarker(UserLocation user, BuildContext context) {
    return Marker(
      point: user.position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Detalles del voluntario'),
                  content: Text('ID: ${user.id}\nNombre: ${user.name}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
          );
        },
        child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
      ),
    );
  }
}

MapMarkerCreator getMarkerCreator(String role) {
  switch (role) {
    case 'victim':
      return VictimMarkerCreator();
    case 'volunteer':
      return VolunteerMarkerCreator();
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
