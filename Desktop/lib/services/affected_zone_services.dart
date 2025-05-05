import 'dart:convert';
import 'package:solidarityhub/services/api_general_service.dart';

class AffectedZoneServices {
  final String baseUrl;
  AffectedZoneServices(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchAffectedZones() async {
    final response = await ApiGeneralService.get('map/affected-zones-with-points');

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((affectedZone) {
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

    return [];
  }
}
