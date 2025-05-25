/*import 'package:flutter/material.dart';
import '../models/necesidad.dart';
import '../services/necesidades_service.dart';

class SolicitudesController {
  final SolicitudesService _service = SolicitudesService();

  Future<List<Solicitud>> cargarSolicitudes(int usuarioId) async {
    return await _service.obtenerSolicitudesPorUsuario(usuarioId);
  }

  Future<void> cancelarSolicitud({
    required BuildContext context,
    required int solicitudId,
    required VoidCallback onSuccess,
  }) async {
    try {
      final exito = await _service.cancelarSolicitud(solicitudId);
      if (exito) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solicitud cancelada.')),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar la solicitud.')),
      );
    }
  }

  Future<void> completarSolicitud({
    required BuildContext context,
    required int solicitudId,
    required VoidCallback onSuccess,
  }) async {
    try {
      final exito = await _service.completarSolicitud(solicitudId);
      if (exito) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solicitud completada.')),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al completar la solicitud.')),
      );
    }
  }
}
*/