import 'package:solidarityhub/LogicPersistence/models/victim.dart';
import 'package:solidarityhub/LogicPersistence/models/volunteer.dart';

class TaskWithDetails {
  final int id;
  final String name;
  final String description;
  final int? adminId;
  final int locationId;
  final List<Volunteer> assignedVolunteers;
  final List<Victim> assignedVictim;

  TaskWithDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.locationId,
    required this.assignedVolunteers,
    required this.assignedVictim,
  });

  factory TaskWithDetails.fromJson(Map<String, dynamic> json) {
    return TaskWithDetails(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      adminId: json['admin_id'],
      locationId: json['location_id'],
      assignedVolunteers:
          (json['assigned_volunteers'] as List)
              .map((volunteer) => Volunteer.fromJson(volunteer))
              .toList(),
      assignedVictim:
          json['assigned_victims'] != null
              ? (json['assigned_victims'] as List)
                  .map((victim) => Victim.fromJson(victim))
                  .toList()
              : [],
    );
  }
}
