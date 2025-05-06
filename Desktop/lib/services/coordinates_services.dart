import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/services/api_services.dart';

class CoordinatesServices {
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
}
