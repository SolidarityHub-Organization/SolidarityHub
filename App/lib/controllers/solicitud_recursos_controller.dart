import 'package:flutter/material.dart';

import '../services/services_recursos.dart';

class SolicitarRecursoController {
  final RecursosService _service = RecursosService();

  final int id;
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  String? recursoSeleccionado;

  SolicitarRecursoController({required this.id});

  Future<void> registrarSolicitud(BuildContext context) async {

    final recurso = recursoSeleccionado;
    final cantidad = cantidadController.text.trim();
    final descripcion = descripcionController.text.trim();

    if (recurso == null || recurso.isEmpty) {
      _mostrarMensaje(context, 'Debe seleccionar un recurso.');
      return;
    }

    if (cantidad.isEmpty) {
      _mostrarMensaje(context, 'Debe indicar la cantidad.');
      return;
    }

    print('--- Datos de la solicitud ---');
    print('Recurso: $recurso');
    print('Cantidad: $cantidad');
    print('Descripción: $descripcion');
    print('ID del afectado: $id');
    print('-----------------------------');

    final Map<String, dynamic> solicitud = {
      'victima_id': id,
      'recurso': recurso,
      'cantidad': int.tryParse(cantidad) ?? 0,
      'descripcion': descripcion,
    };

    final exito = await _service.enviarSolicitudRecurso(solicitud);

    if (exito) {
      _mostrarMensaje(context, 'Solicitud enviada con éxito.');
    } else {
      _mostrarMensaje(context, 'Error al enviar la solicitud.');
    }
  }

  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}
