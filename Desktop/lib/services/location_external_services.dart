import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/services/api_services.dart';

class LocationExternalServices {
  static Future<String> getAddressFromLatLon(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
    );

    final response = await http.get(url, headers: {'Accept': 'application/json', 'User-Agent': 'SolidarityHub App'});

    if (response.statusCode.ok) {
      final data = json.decode(response.body);

      final address = data['address'];
      final road = address['road'] ?? 'Unknown road';
      final city = address['city'] ?? address['town'] ?? address['village'] ?? 'Unknown city';
      final state = address['state'] ?? 'Unknown state';
      final country = address['country'] ?? 'Unknown country';

      final formattedAddress = '$road, $city, $state, $country';
      return formattedAddress;
    } else {
      throw Exception('Failed to get address from latitude and longitude');
    }
  }

  static Future<Map<String, dynamic>?> getLatLonFromAddress(String address) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');

    final response = await http.get(url, headers: {'Accept': 'application/json', 'User-Agent': 'SolidarityHub App'});

    if (response.statusCode.ok) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final firstResult = data[0];
        final double lat = double.parse(firstResult['lat']);
        final double lon = double.parse(firstResult['lon']);

        final String type = firstResult['type'] ?? '';
        final String category = firstResult['category'] ?? '';
        final String osmType = firstResult['osm_type'] ?? '';
        final String osmClass = firstResult['class'] ?? '';

        double zoomLevel = _getRecommendedZoomLevel(
          type: type,
          category: category,
          osmType: osmType,
          osmClass: osmClass,
        );

        return {'location': LatLng(lat, lon), 'zoomLevel': zoomLevel};
      } else {
        throw Exception('No results found for the given address');
      }
    } else {
      throw Exception('Failed to get latitude and longitude from address');
    }
  }

  static double _getRecommendedZoomLevel({
    required String type,
    required String category,
    required String osmType,
    required String osmClass,
  }) {
    if (type.contains('highway') || osmClass == 'highway') {
      if (type.contains('residential') || type.contains('service')) {
        return 17;
      }
      if (type.contains('primary') || type.contains('secondary')) {
        return 16;
      }
      return 15;
    }

    if (type.contains('building') ||
        category.contains('building') ||
        type.contains('house') ||
        type.contains('apartment')) {
      return 18;
    }

    if (osmType == 'node' && (type.contains('place') || type.contains('amenity'))) {
      return 18;
    }

    if (osmClass == 'place' || type.contains('place')) {
      if (type == 'suburb' || type == 'quarter' || type == 'neighbourhood') {
        return 14;
      }
      if (type == 'city' || type == 'town') {
        return 12;
      }
      if (type == 'state' || type == 'region' || type == 'province') {
        return 8;
      }
      if (type == 'country') {
        return 5;
      }
    }

    return 14;
  }
}
