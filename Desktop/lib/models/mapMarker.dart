import 'package:latlong2/latlong.dart';
import 'imap_component.dart';

class MapMarker implements IMapComponent {
  @override
  final String id;
  @override
  final String name;
  @override
  final LatLng position;
  @override
  final String type;
  final String? urgencyLevel;
  final String? time;
  final String? state;
  final Map<String, dynamic>? skillsWithLevel;
  final dynamic physicalDonation;

  @override
  int get count => 1;

  MapMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    this.urgencyLevel,
    this.time,
    this.state,
    this.skillsWithLevel,
    this.physicalDonation,
  });

  // Método para crear una copia con diferentes atributos
  MapMarker copyWith({
    String? id,
    String? name,
    LatLng? position,
    String? type,
    String? urgencyLevel,
    String? time,
    String? state,
    Map<String, dynamic>? skillsWithLevel,
    dynamic physicalDonation,
  }) {
    return MapMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      type: type ?? this.type,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      time: time ?? this.time,
      state: state ?? this.state,
      skillsWithLevel: skillsWithLevel ?? this.skillsWithLevel,
      physicalDonation: physicalDonation ?? this.physicalDonation,
    );
  }

  // Método para crear un MapMarker desde un mapa de datos
  factory MapMarker.fromMap(Map<String, dynamic> map) {
    return MapMarker(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Sin nombre',
      position: LatLng(map['lat'] ?? 0.0, map['lng'] ?? 0.0),
      type: map['type'] ?? 'unknown',
      urgencyLevel: map['urgency_level'],
      time: map['time'],
      state: map['state'],
      skillsWithLevel: map['skills_with_level'],
      physicalDonation: map['physical_donation'],
    );
  }
}
