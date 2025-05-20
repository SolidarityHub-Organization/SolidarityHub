import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/recurso.dart';

class RecursosService {
  final String _baseUrl = 'http://localhost:5170/api/v1';

  Future<List<String>> obtenerNombresRecursos() async {
    final url = Uri.parse('$_baseUrl/need-types');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((recurso) => recurso['name'] as String).toList();
    } else {
      throw Exception('Error al obtener los recursos');
    }
  }

  Future<List<Recurso>> obtenerRecursos() async {
    final url = Uri.parse('$_baseUrl/need-types');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Recurso.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los recursos');
    }
  }

  Future<bool> enviarSolicitudRecurso(Map<String, dynamic> solicitud) async {
    final url = Uri.parse('$_baseUrl/need-types');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(solicitud),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Error del servidor: ${response.statusCode}');
      return false;
    }
  }
}