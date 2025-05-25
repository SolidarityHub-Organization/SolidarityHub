import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Polygon {
  final List<LatLng> points;
  final Color color;
  final Color borderColor;
  final double borderStrokeWidth;

  Polygon({required this.points, required this.color, required this.borderColor, required this.borderStrokeWidth});
}
