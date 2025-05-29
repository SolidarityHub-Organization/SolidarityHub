import 'package:latlong2/latlong.dart';
import 'imap_component.dart';

class MapMarkerCluster implements IMapComponent {
  @override
  final String id;
  @override
  final String name;
  @override
  final LatLng position;
  @override
  final String type;

  final List<IMapComponent> _children;

  @override
  int get count => _children.fold(0, (sum, c) => sum + c.count);

  MapMarkerCluster({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    required List<IMapComponent> children,
  }) : _children = children;


  List<IMapComponent> getChildren() => _children;

  void add(IMapComponent component) {
    _children.add(component);
  }

  void remove(IMapComponent component) {
    _children.remove(component);
  }


  /// Utility: Calculate the center of a cluster from its components
  static LatLng calculateClusterCenter(List<IMapComponent> components) {
    if (components.isEmpty) {
      throw ArgumentError('Cannot calculate center for an empty cluster');
    }

    double totalLat = 0.0;
    double totalLng = 0.0;

    for (var comp in components) {
      totalLat += comp.position.latitude;
      totalLng += comp.position.longitude;
    }

    return LatLng(totalLat / components.length, totalLng / components.length);
  }
}
