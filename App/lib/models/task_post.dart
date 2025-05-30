import 'TaskTime.dart';

class Task {
  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<TaskTime> times;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.times,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      times: json['times'] != null && json['times'] is List
          ? (json['times'] as List)
          .map((t) => TaskTime.fromJson(t as Map<String, dynamic>))
          .toList()
          : [],
    );
  }
}
