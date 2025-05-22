import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TipoSolicitudController {
  final String _baseUrl = 'http://localhost:5170/api/v1';

  Future<void> actualizarEstado({
    required BuildContext context,
    required int solicitudId,
    required String nuevoEstado,
    required VoidCallback onSuccess,
  }) async {
    final url = Uri.parse('$_baseUrl/needs/status/$solicitudId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': nuevoEstado}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
        );
        onSuccess();
      } else {
        throw Exception('Código: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado')),
      );
    }
  }
}