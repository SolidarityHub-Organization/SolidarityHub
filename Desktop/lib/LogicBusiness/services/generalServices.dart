import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicPresentation/dashboard/common_widgets.dart';

class GeneralService {
  final String baseUrl;

  GeneralService(this.baseUrl);

  Future<String> getAddressFromLatLon(double lat, double lon, context) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'SolidarityHub App',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        final road = address['road'] ?? 'Unknown road';
        final city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            'Unknown city';
        final state = address['state'] ?? 'Unknown state';
        final country = address['country'] ?? 'Unknown country';

        final formattedAddress = '$road, $city, $state, $country';
        return formattedAddress;
      } else {
        throw Exception('Failed to get address');
      }
    } catch (e) {
      AppSnackBar.show(
        context: context,
        message: 'Error fetching address: $e',
        type: SnackBarType.success,
      );
      return 'Address not available';
    }
  }
}
