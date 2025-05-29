import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:solidarityhub/utils/route_result.dart';

class RouteServices {
  static const String _apiKey = '5b3ce3597851110001cf62482e986e382e2b4f31963a33817497159c';

  static Future<RouteResult> fetchCarRoute(LatLng routeStart, LatLng routeEnd, List<List<LatLng>> zonasAEvitar) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/json');

    final avoidPolygons = zonasAEvitar.map((zona) {
      final coordinates = zona.map((p) => [p.longitude, p.latitude]).toList();
      return [coordinates];
    }).toList();

    //print('Evitar zonas: $avoidPolygons');
    final body = jsonEncode({
      'coordinates': [
        [routeStart.longitude, routeStart.latitude],
        [routeEnd.longitude, routeEnd.latitude],
      ],
      'options': {
        'avoid_polygons': {'type': 'MultiPolygon', 'coordinates': avoidPolygons},
      },
    });

    final response = await http.post(
      url,
      headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final polyline = data['routes'][0]['geometry'];
      final distance = (data['routes'][0]['summary']['distance'] as num).toDouble();
      final duration = (data['routes'][0]['summary']['duration'] as num).toDouble();
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(polyline);
      final points = decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
      return RouteResult(points: points, distance: distance, duration: duration);
    } else {
      throw Exception('No se pudo obtener la ruta');
    }
  }

  //
  static Future<RouteResult> fetchBikeRoute(LatLng routeStart, LatLng routeEnd, List<List<LatLng>> zonasAEvitar) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/cycling-regular/json');

    final avoidPolygons = zonasAEvitar.map((zona) {
      final coordinates = zona.map((p) => [p.longitude, p.latitude]).toList();
      return [coordinates];
    }).toList();

    final body = jsonEncode({
      'coordinates': [
        [routeStart.longitude, routeStart.latitude],
        [routeEnd.longitude, routeEnd.latitude],
      ],
      'options': {
        'avoid_polygons': {'type': 'MultiPolygon', 'coordinates': avoidPolygons},
      },
    });

    final response = await http.post(
      url,
      headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final polyline = data['routes'][0]['geometry'];
      final distance = (data['routes'][0]['summary']['distance'] as num).toDouble();
      final duration = (data['routes'][0]['summary']['duration'] as num).toDouble();
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(polyline);
      final points = decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
      return RouteResult(points: points, distance: distance, duration: duration);
    } else {
      throw Exception('No se pudo obtener la ruta');
    }
  }

  static Future<RouteResult> fetchWalkingRoute(LatLng routeStart, LatLng routeEnd, List<List<LatLng>> zonasAEvitar) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/foot-walking/json');

    final avoidPolygons = zonasAEvitar.map((zona) {
      final coordinates = zona.map((p) => [p.longitude, p.latitude]).toList();
      return [coordinates];
    }).toList();

    final body = jsonEncode({
      'coordinates': [
        [routeStart.longitude, routeStart.latitude],
        [routeEnd.longitude, routeEnd.latitude],
      ],
      'options': {
        'avoid_polygons': {'type': 'MultiPolygon', 'coordinates': avoidPolygons},
      },
    });

    final response = await http.post(
      url,
      headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final polyline = data['routes'][0]['geometry'];
      final distance = (data['routes'][0]['summary']['distance'] as num).toDouble();
      final duration = (data['routes'][0]['summary']['duration'] as num).toDouble();
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(polyline);
      final points = decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
      return RouteResult(points: points, distance: distance, duration: duration);
    } else {
      throw Exception('No se pudo obtener la ruta');
    }
  }
}
