import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/location.dart';
import 'package:solidarityhub/models/victim.dart';

class TaskWithDetails {
  final int id;
  final String name;
  final String description;
  final int? adminId;
  final int locationId;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Volunteer> assignedVolunteers;
  final List<Victim> assignedVictim;
  final Location? location;

  TaskWithDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.locationId,
    required this.startDate,
    this.endDate,
    required this.assignedVolunteers,
    required this.assignedVictim,
    this.location,
  });

  factory TaskWithDetails.fromJson(Map<String, dynamic> json) {
    return TaskWithDetails(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      adminId: json['admin_id'],
      locationId: json['location_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      assignedVolunteers:
          (json['assigned_volunteers'] as List).map((volunteer) => Volunteer.fromJson(volunteer)).toList(),
      assignedVictim:
          json['assigned_victims'] != null
              ? (json['assigned_victims'] as List).map((victim) => Victim.fromJson(victim)).toList()
              : [],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }
}
