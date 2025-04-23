class AffectedZone {
  final int id;
  final String name;
  final String description;
  final int hazardLevel;
  final int adminId;
  final List<Point> points;

  AffectedZone({
    required this.id,
    required this.name,
    required this.description,
    required this.hazardLevel,
    required this.adminId,
    required this.points,
  });

  factory AffectedZone.fromJson(Map<String, dynamic> json) {
    return AffectedZone(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      hazardLevel: json['hazard_level'],
      adminId: json['admin_id'],
      points: (json['points'] as List)
          .map((point) => Point.fromJson(point))
          .toList(),
    );
  }
}

class Point {
  final double latitude;
  final double longitude;

  Point({required this.latitude, required this.longitude});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}