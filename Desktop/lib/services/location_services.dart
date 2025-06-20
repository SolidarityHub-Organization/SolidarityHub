import 'dart:convert';
import 'api_services.dart';
import 'package:http/http.dart' as http;

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
              'skills_with_level': location['skills_with_level'],
            };
          }).toList();
    }

    return locations;
  }

  static Future<List<Map<String, dynamic>>> fetchPickupPointLocations() async {
    final response = await ApiServices.get('map/pickup-points-with-location');
    List<Map<String, dynamic>> locations = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      locations =
          data.map((location) {
            // Calcular la cantidad total de donaciones sumando las cantidades de cada item
            int totalDonations = 0;
            if (location['physical_donation'] is List) {
              List<dynamic> donations = location['physical_donation'];
              for (var donation in donations) {
                if (donation is Map && donation.containsKey('quantity')) {
                  // Convertir quantity a entero de forma segura
                  var quantity = donation['quantity'];
                  if (quantity is int) {
                    totalDonations += quantity;
                  } else if (quantity != null) {
                    // Intentar convertir otros tipos a entero
                    totalDonations += int.tryParse(quantity.toString()) ?? 0;
                  }
                }
              }
            }

            return {
              'id': location['id'],
              'name': location['name'],
              'latitude': location['latitude'],
              'longitude': location['longitude'],
              'type': location['type'],
              'physical_donation': location['physical_donation'],
              'quantity': totalDonations,
            };
          }).toList();
    }

    return locations;
  }

  static Future<List<Map<String, dynamic>>> fetchMeetingPointLocations() async {
    final response = await ApiServices.get('map/meeting-points-with-location');
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

  static Future<bool> createLocationsForZone(int zoneId, List<Map<String, dynamic>> points) async {
    try {
      final response = await ApiServices.post(
        'affected-zones/$zoneId/locations',
        body: points,
      );

      if (response.statusCode.ok) {
        return true;
      } else {
        print('Failed to create locations: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating locations for zone: $e');
      return false;
    }
  }

  static Future<bool> createZoneWithLocations(
    Map<String, dynamic> zoneData,
    List<Map<String, dynamic>> points,
  ) async {
    try {
      // 1. Create the affected zone
      final zoneResponse = await ApiServices.post(
        'affected-zones',
        body: zoneData,
      );

      if (zoneResponse.statusCode.ok) {
        // parse the JSON response first
        final zone = jsonDecode(zoneResponse.body);
        final int? zoneId = zone['id'];
        
        if (zoneId == null) {
          print('Zone ID not found in response.');
          return false;
        }

        // 2. Create the locations for the new zone
        final locationsResponse = await ApiServices.post(
          'affected-zones/$zoneId/locations',
          body: points,
        );

        return locationsResponse.statusCode.ok;
      } else {
        print('Failed to create zone: ${zoneResponse.statusCode} - ${zoneResponse.body}');
        return false;
      }
    } catch (e) {
      print('Error creating zone with locations: $e');
      return false;
    }
  }

  static Future<bool> deleteZoneWithLocations(int zoneId) async {
  try {
    // 1. Delete all locations for the zone
    final locationsResponse = await ApiServices.delete('affected-zones/$zoneId/locations');
    if (!locationsResponse.statusCode.ok && locationsResponse.statusCode != 404) {
      print('Failed to delete locations: ${locationsResponse.statusCode} - ${locationsResponse.body}');
      return false;
    }

    // 2. Delete the zone itself
    final zoneResponse = await ApiServices.delete('affected-zones/$zoneId');
    if (zoneResponse.statusCode.ok || zoneResponse.statusCode == 404) {
      print('Zone and all associated locations deleted successfully');
      return true;
    } else {
      print('Failed to delete zone: ${zoneResponse.statusCode} - ${zoneResponse.body}');
      return false;
    }
  } catch (e) {
    print('Error deleting zone with locations: $e');
    return false;
  }
}
}
