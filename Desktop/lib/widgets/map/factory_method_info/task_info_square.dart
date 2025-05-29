import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import 'info_square_factory.dart';
import '../../../services/location_external_services.dart';
import '../decorator/info_square_decorator.dart';

class TaskInfoSquare implements InfoSquare {
  // Método para obtener el icono según el estado
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

  // Método para obtener el color según el estado
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

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return FutureBuilder<String>(
      future: LocationExternalServices.getAddressFromLatLon(mapMarker.position.latitude, mapMarker.position.longitude),
      builder: (context, snapshot) {
        String address = snapshot.hasData ? snapshot.data! : 'Cargando dirección...';

        // Definir colores temáticos para tareas
        final Color primaryColor = Colors.orange;
        final Color secondaryColor = Colors.orange.shade300; // Crear las filas de información
        List<InfoRowData> rows = [
          InfoRowData(icon: Icons.description, label: 'Nombre', value: mapMarker.name),
          InfoRowData(icon: Icons.location_on, label: 'Ubicación', value: address),
          InfoRowData(
            icon: Icons.gps_fixed,
            label: 'Coordenadas',
            value:
                '${mapMarker.position.latitude.toStringAsFixed(6)}, ${mapMarker.position.longitude.toStringAsFixed(6)}',
          ),
        ];

        // Agregar estado si existe
        if (mapMarker.state != null) {
          rows.add(
            InfoRowData(
              icon: _getStateIcon(mapMarker.state),
              label: 'Estado',
              value: mapMarker.state!,
              valueColor: _getStateColor(mapMarker.state),
            ),
          );
        }

        // Agregar habilidades si existen
        if (mapMarker.skillsWithLevel != null) {
          rows.add(
            InfoRowData(
              icon: Icons.star,
              label: 'Habilidades',
              value: mapMarker.skillsWithLevel!.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
            ),
          );
        }

        // Usar el decorador completo
        InfoSquare emptySquare = EmptyInfoSquare();
        InfoSquare decoratedSquare = CompleteStyleDecorator.create(
          emptySquare,
          title: 'Detalles de la tarea',
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          mainIcon: Icons.task_alt,
          rows: rows,
        );

        return decoratedSquare.buildInfoSquare(mapMarker);
      },
    );
  }
}
