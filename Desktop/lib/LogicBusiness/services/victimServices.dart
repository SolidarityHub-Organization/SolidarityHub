import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../LogicPersistence/models/victim.dart';

class VictimService {
  final String baseUrl;

  VictimService(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchVictimNeedsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/need-types/victim-counts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/victims/with-location'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((location) {
          return {
            'id': location['id'], // ID de la víctima
            'name': location['name'], // Nombre de la víctima
            'latitude': location['latitude'], // Latitud
            'longitude': location['longitude'], // Longitud
          };
        }).toList();
      } else {
        print('Error al obtener las ubicaciones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');
      return [];
    }
  }
}
