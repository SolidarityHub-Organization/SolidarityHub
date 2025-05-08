class NotificationModel {
  final int id;
  final String name;
  final String description;
  final int? volunteerId;
  final int? victimId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.name,
    required this.description,
    this.volunteerId,
    this.victimId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      volunteerId: json['volunteer_id'],
      victimId: json['victim_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
