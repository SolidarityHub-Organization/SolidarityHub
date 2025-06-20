import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/services/api_services.dart';
import 'package:http/http.dart' as http;

class AffectedZoneServices {
  static const String baseUrl = 'http://localhost:5170/api/v1';
  static Future<Map<String, dynamic>> createAffectedZone(Map<String, dynamic> zoneData) async {
  try {
    Map<String, dynamic> transformedData = {
      'name': zoneData['name'],
      'description': zoneData['description'],
      'hazard_level': zoneData['hazard_level'],
      'admin_id': zoneData['admin_id'] ?? 1,
      'points': zoneData['points'] ?? [],
    };

    print('Making request to: $baseUrl/affected-zones');
    print('Transformed request body: ${json.encode(transformedData)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/affected-zones'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(transformedData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Service error: $e');
    throw Exception('Error creating affected zone: $e');
  }
}

  static Future<bool> deleteAffectedZone(int zoneId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/affected-zones/$zoneId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting affected zone: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAffectedZones() async {
    final Map<String, dynamic> data = {
      'description':'Obtener mapa de calor',
      'Strategy':'heatmap'
    };

  final response = await ApiServices.post('map/mostrar', body: (data));

    List<Map<String, dynamic>> affectedZones = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      affectedZones =
          data.map((affectedZone) {
            return {
              'id': affectedZone['id'],
              'name': affectedZone['name'],
              'description': affectedZone['description'],
              'hazard_level': affectedZone['hazard_level'],
              'admin_id': affectedZone['admin_id'],
              'points':
                  (affectedZone['points'] as List)
                      .map((point) => {'latitude': point['latitude'], 'longitude': point['longitude']})
                      .toList(),
            };
          }).toList();
    }

    return affectedZones;
  }
  
  static Future<List<List<LatLng>>> fetchAffectedZonesPoints() async {
    final Map<String, String> data = {
      'description': 'Obtener mapa de calor',
      'Strategy': 'heatmap'
    };

  final response = await ApiServices.post('map/mostrar', body: (data));
  List<List<LatLng>> affectedZonesPoints = [];

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    affectedZonesPoints = data.map<List<LatLng>>((affectedZone) {
      final points = affectedZone['points'] as List;
      List<LatLng> poly = points.map<LatLng>((point) => LatLng(point['latitude'], point['longitude'])).toList();
      if (poly.isNotEmpty && (poly.first.latitude != poly.last.latitude || poly.first.longitude != poly.last.longitude)) {
        poly.add(poly.first);
      }
      return poly;
    }).toList();
  }

  return affectedZonesPoints;
}


}
