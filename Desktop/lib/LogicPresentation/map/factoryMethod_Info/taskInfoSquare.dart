import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'infoSquareFactory.dart';
import 'package:geocoding/geocoding.dart';

class TaskInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      // Usa FutureBuilder para manejar la operación asíncrona
      future: _getAddressFromLatLng(mapMarker.position.latitude, mapMarker.position.longitude, 'es'),
      builder: (context, snapshot) {
        // Texto por defecto mientras carga o si hay error
        String locationText = 'Cargando ubicación...';

        if (snapshot.hasData) {
          locationText = 'Ubicación: ${snapshot.data}';
        } else if (snapshot.hasError) {
          locationText = 'Error: ${snapshot.error}';
        }

        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade50, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
            border: Border.all(color: Colors.orange.shade300, width: 2.0), // Borde más grueso
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.orange, size: 28), // Icono más grande
                  SizedBox(width: 12),
                  Text(
                    'Detalles de la tarea',
                    style: TextStyle(
                      fontSize: 24, // Texto más grande
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.orange.shade300, thickness: 2.0, height: 32), // Divisor más grueso y alto
              SizedBox(height: 20), // Más espacio

              SizedBox(height: 12),
              _buildInfoRow(Icons.description, 'Nombre: ${mapMarker.name}', 22),
              SizedBox(height: 12),
              _buildInfoRow(Icons.location_on, locationText, 22),
              SizedBox(height: 50), // Espacio mayor antes del botón
              Center(
                // Aseguramos que está centrado horizontalmente
                child: ElevatedButton(
                  onPressed: () {
                    // Acción para ver más detalles
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Botón más grande
                    textStyle: TextStyle(fontSize: 18), // Texto de botón más grande
                  ),
                  child: Text('Ver más detalles'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude, String localeIdentifier) async {
    try {
      print('Intentando obtener dirección con coordenadas: $latitude, $longitude');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: localeIdentifier,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Verificar que los campos no sean nulos
        String street = place.street ?? 'Desconocida';
        String locality = place.locality ?? 'Desconocida';
        String country = place.country ?? 'Desconocida';

        return '$street, $locality, $country';
      } else {
        return 'Dirección desconocida';
      }
    } catch (e) {
      return 'Error al obtener dirección: $e';
    }
  }

  Widget _buildInfoRow(IconData icon, String text, double fontSize) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.orange), // Icono más grande
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize), // Tamaño de texto parametrizado
          ),
        ),
      ],
    );
  }
}
