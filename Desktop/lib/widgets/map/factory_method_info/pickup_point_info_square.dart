import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';

class PickupPointInfoSquare implements InfoSquare {

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    final donations = mapMarker.physicalDonation is List ? mapMarker.physicalDonation as List : null;

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
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
            border: Border.all(color: Color.fromARGB(255, 30, 136, 229), width: 2.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color.fromARGB(255, 30, 136, 229)),
                    ),
                    child: Icon(Icons.local_shipping, color: Color.fromARGB(255, 30, 136, 229), size: 36),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Detalles del punto de recogida',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 30, 136, 229)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              Divider(color: Color.fromARGB(255, 100, 181, 246), thickness: 2.0, height: 32),

              SizedBox(height: 40),

              _buildInfoRowEnhanced(
                icon: Icons.location_pin,
                label: 'Nombre',
                value: mapMarker.name,
              ),

              SizedBox(height: 30),

              _buildInfoRowEnhanced(
                icon: Icons.location_on,
                label: 'Ubicación',
                value: address,
              ),

              if (mapMarker.time != null) ...[
                SizedBox(height: 30),
                _buildInfoRowEnhanced(
                  icon: Icons.access_time,
                  label: 'Horario',
                  value: mapMarker.time.toString(),
                ),
              ],

              if (donations != null && donations.isNotEmpty) ...[
                SizedBox(height: 30),
                _buildInfoRowEnhanced(
                  icon: Icons.card_giftcard,
                  label: 'Donaciones',
                  value: '${donations.length}',
                ),
              ],

              SizedBox(height: 50),
              Divider(color: Color.fromARGB(255, 100, 181, 246), thickness: 1.0),

              SizedBox(height: 20),

              Center(
                child: Text(
                  'Información actualizada',
                  style: TextStyle(color: Color.fromARGB(255, 30, 136, 229), fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
        border: Border.all(color: Color.fromARGB(255, 100, 181, 246)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Color.fromARGB(255, 30, 136, 229)),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 30, 136, 229)),
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