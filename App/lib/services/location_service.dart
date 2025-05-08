import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class LocationService {
  static Future<Location> fetchLocation(int locationId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/location/affectedplaces/$locationId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Location.fromJson(json.decode(response.body));
    } else {
      throw Exception('No se pudo cargar la localización');
    }
  }
}