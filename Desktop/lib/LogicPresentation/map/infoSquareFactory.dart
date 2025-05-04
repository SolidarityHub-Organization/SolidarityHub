import 'package:flutter/material.dart';
import '../../models/mapMarker.dart';

abstract class InfoSquare {
  Widget buildInfoSquare(MapMarker mapMarker);
}

class VictimInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(24.0), // Padding más grande
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
        border: Border.all(color: Colors.red.shade300, width: 2.0), // Borde más grueso
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.red.shade700, size: 28), // Icono más grande
              SizedBox(width: 12),
              Text(
                'Detalles del afectado',
                style: TextStyle(
                  fontSize: 24, // Texto más grande
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          Divider(color: Colors.red.shade300, thickness: 2.0, height: 32), // Divisor más grueso y alto
          SizedBox(height: 20), // Más espacio

          SizedBox(height: 12),
          _buildInfoRow(Icons.person_pin, 'Nombre: ${mapMarker.name}', 22),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Ubicación: ${mapMarker.position.latitude.toStringAsFixed(4)}, ${mapMarker.position.longitude.toStringAsFixed(4)}',
            22,
          ),
          SizedBox(height: 50), // Espacio mayor antes del botón
          Center(
            // Aseguramos que está centrado horizontalmente
            child: ElevatedButton(
              onPressed: () {
                // Acción para ver más detalles
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
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
  }

  Widget _buildInfoRow(IconData icon, String text, double fontSize) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.red.shade600), // Icono más grande
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

class VolunteerInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(24.0), // Padding más grande
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
        border: Border.all(color: Colors.green.shade300, width: 2.0), // Borde más grueso
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.green, size: 28), // Icono más grande
              SizedBox(width: 12),
              Text(
                'Detalles del voluntario',
                style: TextStyle(
                  fontSize: 24, // Texto más grande
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          Divider(color: Colors.green.shade300, thickness: 2.0, height: 32), // Divisor más grueso y alto
          SizedBox(height: 20), // Más espacio

          SizedBox(height: 12),
          _buildInfoRow(Icons.person_pin, 'Nombre: ${mapMarker.name}', 22),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Ubicación: ${mapMarker.position.latitude.toStringAsFixed(4)}, ${mapMarker.position.longitude.toStringAsFixed(4)}',
            22,
          ),
          SizedBox(height: 50), // Espacio mayor antes del botón
          Center(
            // Aseguramos que está centrado horizontalmente
            child: ElevatedButton(
              onPressed: () {
                // Acción para ver más detalles
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
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
  }

  Widget _buildInfoRow(IconData icon, String text, double fontSize) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.green), // Icono más grande
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

class TaskInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(24.0), // Padding más grande
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
          _buildInfoRow(
            Icons.location_on,
            'Ubicación: ${mapMarker.position.latitude.toStringAsFixed(4)}, ${mapMarker.position.longitude.toStringAsFixed(4)}',
            22,
          ),
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

InfoSquare getInfoSquare(String role) {
  switch (role) {
    case 'victim':
      return VictimInfoSquare();
    case 'volunteer':
      return VolunteerInfoSquare();
    case 'task':
      return TaskInfoSquare();
    default:
      throw Exception('Tipo de usuario desconocido: $role');
  }
}
