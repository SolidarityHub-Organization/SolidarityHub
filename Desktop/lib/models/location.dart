class Location {
  final int id;
  final double latitude;
  final double longitude;
  final int? victimId;
  final int? volunteerId;

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.victimId,
    this.volunteerId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      victimId: json['victim_id'],
      volunteerId: json['volunteer_id'],
    );
  }
}
