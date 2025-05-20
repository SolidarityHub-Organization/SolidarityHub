import 'package:flutter/material.dart';
import '../models/recurso.dart';
import '../services/services_recursos.dart';

class SolicitarRecursoController {
  final RecursosService _service = RecursosService();

  final int id;
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  Recurso? recursoSeleccionado;

  SolicitarRecursoController({required this.id});

  Future<void> registrarSolicitud(BuildContext context) async {

    final recurso = recursoSeleccionado;
    final cantidad = cantidadController.text.trim();
    final descripcion = descripcionController.text.trim();

    if (recurso == null) {
      _mostrarMensaje(context, 'Debe seleccionar un recurso.');
      return;
    }

    if (cantidad.isEmpty) {
      _mostrarMensaje(context, 'Debe indicar la cantidad.');
      return;
    }

    //print('--- Datos de la solicitud ---');
    //print('victima_id: $id');
    //print('recurso_nombre: ${recurso.name}');
    //print('recurso_id: ${recurso.id}');
    //print('cantidad: $cantidad');
    //print('descripcion: $descripcion');
    //print('-----------------------------');

    final Map<String, dynamic> solicitud = {
      'name': recurso.name,
      'description': descripcion,
      'victim_id': id,
      'need_type_id': recurso.id,
      //'cantidad': int.tryParse(cantidad) ?? 0,
    };
    print(solicitud);

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
