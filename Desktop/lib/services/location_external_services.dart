import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationExternalServices {
  // Método para obtener una dirección a partir de coordenadas
  static Future<String> getAddressFromLatLon(double lat, double lon) async {
    try {
      // Utilizamos la API de OpenStreetMap para la geocodificación inversa
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'SolidarityHub'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Dirección desconocida';
      } else {
        return 'Error al obtener la dirección';
      }
    } catch (e) {
      return 'No se pudo conectar con el servicio de geocodificación';
    }
  }

  // Método para buscar coordenadas a partir de una dirección
  static Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      // Encoding the address for URL
      final encodedAddress = Uri.encodeComponent(address);

      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress'),
        headers: {'User-Agent': 'SolidarityHub'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data.first;
          return LatLng(double.parse(location['lat']), double.parse(location['lon']));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
