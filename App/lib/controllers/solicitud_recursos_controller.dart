import 'package:flutter/material.dart';

class SolicitarRecursoController {
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  String? recursoSeleccionado;

  void registrarSolicitud(BuildContext context) {
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
    print('-----------------------------');

    _mostrarMensaje(context, 'Solicitud registrada con éxito.');
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
