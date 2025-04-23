import 'dart:convert';
import 'package:http/http.dart' as http;

class AffectedZoneServices {
  final String baseUrl;
  AffectedZoneServices(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchAffectedZones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/map/affected-zones-with-points'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((affectedZone) {
          return {
            'id': affectedZone['id'],
            'name': affectedZone['name'],
            'description': affectedZone['description'],
            'hazard_level': affectedZone['hazard_level'],
            'admin_id': affectedZone['admin_id'],
            'points': (affectedZone['points'] as List).map((point) => {
                  'latitude': point['latitude'],
                  'longitude': point['longitude'],
                }).toList(),
          };
        }).toList();
      } else {
        print('Error al obtener las zonas afectadas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');
      return [];
    }
  }
}

