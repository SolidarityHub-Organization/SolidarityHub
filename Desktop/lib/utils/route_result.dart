import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distance; // en metros
  final double duration; // en segundos

  RouteResult({required this.points, required this.distance, required this.duration});
}