class Task {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endDate;
  final int adminId;
  final int locationId;
  final double longitude;
  final double latitude;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.startDate,
    this.endDate,
    required this.adminId,
    required this.locationId,
    required this.longitude,
    required this.latitude,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      longitude: json['longitude'],
      latitude: json['latitude'],
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      adminId: json['admin_id'],
      locationId: json['location_id'],
    );
  }
}