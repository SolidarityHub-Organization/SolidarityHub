import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';

class TaskInfoSquare implements InfoSquare {
  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10.0, offset: Offset(0, 5))],
        border: Border.all(color: Colors.orange.shade300, width: 2.0),
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
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Icon(Icons.task_alt, color: Colors.orange, size: 36),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Detalles de la tarea',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),

          SizedBox(height: 40),

          Divider(color: Colors.orange.shade300, thickness: 2.0, height: 32),

          SizedBox(height: 40),

          // Información con diseño mejorado
          _buildInfoRowEnhanced(icon: Icons.description, label: 'Nombre', value: mapMarker.name),

          SizedBox(height: 30),

          _buildInfoRowEnhanced(
            icon: Icons.location_on,
            label: 'Ubicación',
            value:
                '${mapMarker.position.latitude.toStringAsFixed(4)}, ${mapMarker.position.longitude.toStringAsFixed(4)}',
          ),

          SizedBox(height: 30),

          if (mapMarker.state != null)
            _buildInfoRowEnhanced(
              icon: _getStateIcon(mapMarker.state),
              label: 'Estado',
              value: mapMarker.state!,
              valueColor: _getStateColor(mapMarker.state),
            ),

          SizedBox(height: 50),

          Divider(color: Colors.orange.shade200, thickness: 1.0),

          SizedBox(height: 20),

          Center(
            child: Text(
              'Información actualizada',
              style: TextStyle(color: Colors.orange.shade400, fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStateIcon(String? state) {
    if (state == null) return Icons.assignment_outlined;

    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Icons.assignment_turned_in_rounded;
      case 'asignado':
        return Icons.assignment_outlined;
      case 'pendiente':
        return Icons.assignment_return_rounded;
      case 'cancelado':
        return Icons.assignment_late_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _getStateColor(String? state) {
    if (state == null) return Colors.orange;

    String stateStr = state.toString().toLowerCase().trim();

    switch (stateStr) {
      case 'completado':
        return Colors.green;
      case 'asignado':
        return Colors.orange;
      case 'pendiente':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
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
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.orange),
              SizedBox(width: 10),
              Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
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
