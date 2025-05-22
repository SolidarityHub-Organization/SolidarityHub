import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/TipoSolicitud.dart';

class TipoSolicitudService {
  final String _baseUrl = 'http://localhost:5170/api/v1';

  Future<List<TipoSolicitud>> obtenerTiposSolicitud(int id) async {
    final url = Uri.parse('$_baseUrl/needs/victim-details/$id'); // Cambia la ruta si es necesario
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TipoSolicitud.fromJson(json)).toList();
    } else {
      print('Error del servidor: ${response.statusCode}');
      throw Exception('Error al obtener los tipos de solicitud');
    }
  }
}
