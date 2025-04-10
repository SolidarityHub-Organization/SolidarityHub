class TaskWithDetails {
  final int id;
  final String name;
  final String description;
  final int? adminId;
  final int locationId;
  final List<dynamic> assignedVolunteers;

  TaskWithDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.locationId,
    required this.assignedVolunteers,
  });

  factory TaskWithDetails.fromJson(Map<String, dynamic> json) {
    return TaskWithDetails(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      adminId: json['admin_id'],
      locationId: json['location_id'],
      assignedVolunteers: List<dynamic>.from(json['assigned_volunteers']),
    );
  }
}
