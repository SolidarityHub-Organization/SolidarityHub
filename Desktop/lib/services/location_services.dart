import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'api_services.dart';

class LocationServices {
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

  /// Searches for an address using the OpenStreetMap Nominatim API
  /// Returns a map with LatLng coordinates and recommended zoom level if found, null otherwise
  static Future<Map<String, dynamic>?> searchAddress(String address) async {
    if (address.isEmpty) {
      return null;
    }

    try {
      // Encode the address for URL
      final encodedAddress = Uri.encodeComponent(address);
      // Use Nominatim geocoding service (OpenStreetMap)
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1');

      final response = await http.get(url, headers: {'User-Agent': 'SolidarityHub/1.0'});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final firstResult = data[0];
          final double lat = double.parse(firstResult['lat']);
          final double lon = double.parse(firstResult['lon']);
          
          // extract type information
          final String type = firstResult['type'] ?? '';
          final String category = firstResult['category'] ?? '';
          final String osmType = firstResult['osm_type'] ?? '';
          final String osmClass = firstResult['class'] ?? '';
          
          // determine appropriate zoom level
          double zoomLevel = _getRecommendedZoomLevel(
            type: type, 
            category: category,
            osmType: osmType,
            osmClass: osmClass
          );
          
          return {
            'location': LatLng(lat, lon),
            'zoomLevel': zoomLevel
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error searching address: $e');
      return null;
    }
  }


  static double _getRecommendedZoomLevel({
    required String type,
    required String category,
    required String osmType,
    required String osmClass,
  }) {
    // street level elements
    if (type.contains('highway') || osmClass == 'highway') {
      if (type.contains('residential') || type.contains('service')) {
        return 17; // street level
      }
      if (type.contains('primary') || type.contains('secondary')) {
        return 16; // main road
      }
      return 15; // general road
    }
    
    // buildings and specific places
    if (type.contains('building') || category.contains('building') ||
        type.contains('house') || type.contains('apartment')) {
      return 18; // building level
    }
    
    // points of interest
    if (osmType == 'node' && (type.contains('place') || type.contains('amenity'))) {
      return 18; // specific point of interest
    }
    
    // administrative areas
    if (osmClass == 'place' || type.contains('place')) {
      if (type == 'suburb' || type == 'quarter' || type == 'neighbourhood') {
        return 14; // district/neighborhood
      }
      if (type == 'city' || type == 'town') {
        return 12; // city level
      }
      if (type == 'state' || type == 'region' || type == 'province') {
        return 8; // state/region level
      }
      if (type == 'country') {
        return 5; // country level
      }
    }
    
    // default zoom level (neighborhood view)
    return 14;
  }
}
