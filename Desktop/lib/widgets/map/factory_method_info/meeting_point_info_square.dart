import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'info_square_factory.dart';

class MeetingPointInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
        border: Border.all(color: Color.fromARGB(255, 56, 142, 60), width: 2.0),
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
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color.fromARGB(255, 56, 142, 60)),
                ),
                child: Icon(Icons.group, color: Color.fromARGB(255, 56, 142, 60), size: 36),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Detalles del punto de encuentro',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 56, 142, 60)),
                ),
              ),
            ],
          ),

          SizedBox(height: 40),

          Divider(color: Color.fromARGB(255, 129, 199, 132), thickness: 2.0, height: 32),

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
            value: '${mapMarker.position.latitude.toStringAsFixed(4)}, ${mapMarker.position.longitude.toStringAsFixed(4)}',
          ),

          if (mapMarker.time != null) ...[
            SizedBox(height: 30),
            _buildInfoRowEnhanced(
              icon: Icons.access_time,
              label: 'Horario',
              value: mapMarker.time.toString(),
            ),
          ],

          SizedBox(height: 50),
          Divider(color: Color.fromARGB(255, 129, 199, 132), thickness: 1.0),

          SizedBox(height: 20),

          Center(
            child: Text(
              'Información actualizada',
              style: TextStyle(color: Color.fromARGB(255, 56, 142, 60), fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ),
        ],
      ),
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
        border: Border.all(color: Color.fromARGB(255, 129, 199, 132)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Color.fromARGB(255, 56, 142, 60)),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 56, 142, 60)),
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