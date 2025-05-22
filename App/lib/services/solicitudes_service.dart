import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solicitud.dart';

class SolicitudesService {
  final String _baseUrl = 'http://localhost:5170/api/v1';

  Future<List<Solicitud>> obtenerSolicitudesPorUsuario(int usuarioId) async {
    final url = Uri.parse('$_baseUrl/solicitudes/$usuarioId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Solicitud.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las solicitudes');
    }
  }

  Future<bool> cancelarSolicitud(int id) async {
    final url = Uri.parse('$_baseUrl/needs/status/$id');
    final response = await http.post(url);
    return response.statusCode == 200;
  }

  Future<bool> completarSolicitud(int id) async {
    final url = Uri.parse('$_baseUrl/needs/$id/completar');
    final response = await http.post(url);
    return response.statusCode == 200;
  }
}