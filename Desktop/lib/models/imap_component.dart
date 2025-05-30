import 'package:latlong2/latlong.dart';

abstract class IMapComponent {
  String get id;
  String get name;
  LatLng get position;
  String get type;
  
  int get count;
}