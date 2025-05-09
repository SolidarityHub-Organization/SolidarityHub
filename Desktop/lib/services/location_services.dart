import 'dart:convert';
import 'api_services.dart';

class LocationServices {
  static Future<Map<String, dynamic>> fetchLocationById(int id) async {
    final response = await ApiServices.get('locations/$id');

    if (response.statusCode.ok) {
      return json.decode(response.body);
    }

    return {};
  }

  static Future<List<Map<String, dynamic>>> fetchVolunteerLocations() async {
    final response = await ApiServices.get('map/volunteers-with-location');
    List<Map<String, dynamic>> locations = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      locations =
          data.map((location) {
            return {
              'id': location['id'],
              'name': location['name'],
              'latitude': location['latitude'],
              'longitude': location['longitude'],
              'type': location['type'],
            };
          }).toList();
    }

    return locations;
  }

  static Future<List<Map<String, dynamic>>> fetchVictimLocations() async {
    final response = await ApiServices.get('map/victims-with-location');
    List<Map<String, dynamic>> locations = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      locations =
          data.map((location) {
            return {
              'id': location['id'],
              'name': location['name'],
              'latitude': location['latitude'],
              'longitude': location['longitude'],
              'type': location['type'],
              'urgencyLevel': location['urgency_level'],
            };
          }).toList();
    }

    return locations;
  }

  static Future<List<Map<String, dynamic>>> fetchTaskLocations() async {
    final response = await ApiServices.get('map/tasks-with-location');
    List<Map<String, dynamic>> locations = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      locations =
          data.map((location) {
            return {
              'id': location['id'],
              'name': location['name'],
              'latitude': location['latitude'],
              'longitude': location['longitude'],
              'type': location['type'],
              'state': location['state']?.toString(),
            };
          }).toList();
    }

    return locations;
  }
}
