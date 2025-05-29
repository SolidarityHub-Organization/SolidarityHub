import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/necesidad.dart';

class NecesidadesService {
  final String _baseUrl = 'http://localhost:5170/api/v1';

  Future<List<Necesidad>> obtenerTodasLasNecesidades() async {
    final url = Uri.parse('$_baseUrl/needs/for-volunteer');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Necesidad.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las necesidades');
    }
  }
}
