import 'package:flutter/material.dart';
import 'package:solidarityhub/services/location_services.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';

class VolunteerInfoSquare implements InfoSquare {

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(
        mapMarker.position.latitude,
        mapMarker.position.longitude,
      ),
      builder: (context, snapshot) {
        String address = snapshot.hasData 
            ? snapshot.data!
            : 'Cargando dirección...';

        return Container(
          padding: const EdgeInsets.all(32.0), // Aumentado el padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade50, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(16.0), // Aumentado el radio
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
            border: Border.all(color: Color.fromARGB(255, 255, 79, 135), width: 2.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado con icono y título
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color.fromARGB(255, 255, 79, 135)),
                    ),
                    child: Icon(Icons.volunteer_activism, color: Color.fromARGB(255, 255, 79, 135), size: 36),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Detalles del voluntario',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 79, 135)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40), // Mayor espacio vertical

              Divider(color: Color.fromARGB(255, 255, 143, 180), thickness: 2.0, height: 32),

              SizedBox(height: 40), // Mayor espacio vertical
              // Información con diseño mejorado
              _buildInfoRowEnhanced(icon: Icons.person_pin, label: 'Nombre', value: mapMarker.name),

              SizedBox(height: 30), // Mayor espacio entre elementos

              _buildInfoRowEnhanced(
                icon: Icons.location_on,
                label: 'Ubicación',
                value: address,
              ),

              SizedBox(height: 50), // Espacio al final
              // Decoración adicional en la parte inferior
              Divider(color: Color.fromARGB(255, 255, 143, 180), thickness: 1.0),

              SizedBox(height: 20),

              Center(
                child: Text(
                  'Información actualizada',
                  style: TextStyle(color: Color.fromARGB(255, 255, 79, 135), fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget mejorado para las filas de información
  Widget _buildInfoRowEnhanced({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromARGB(255, 255, 143, 180)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Color.fromARGB(255, 255, 79, 135)),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 79, 135)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
