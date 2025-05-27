import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/services/api_services.dart';

class AffectedZoneServices {
  final String baseUrl;
  AffectedZoneServices(this.baseUrl);

  static Future<List<Map<String, dynamic>>> fetchAffectedZones() async {
    final response = await ApiServices.get('heatmap/mostrar');
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
  final response = await ApiServices.get('heatmap/mostrar');
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
