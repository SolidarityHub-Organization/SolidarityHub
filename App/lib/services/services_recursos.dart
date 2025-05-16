import 'package:http/http.dart' as http;
import 'dart:convert';

class RecursosService {
  final String _baseUrl = 'http://localhost:5170/api/v1'; // Sustituir con tu URL real

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
}