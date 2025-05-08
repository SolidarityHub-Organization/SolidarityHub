import 'package:solidarityhub/models/location.dart';
import 'package:solidarityhub/models/skill.dart';

class Volunteer {
  final int id;
  final String email;
  final String name;
  final String surname;
  final int prefix;
  final String phoneNumber;
  final String address;
  final String identification;
  final int? locationId;
  final Location? location;
  final List<Skill> skills;

  Volunteer({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.prefix,
    required this.phoneNumber,
    required this.address,
    required this.identification,
    required this.locationId,
    this.location,
    required this.skills,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      prefix: json['prefix'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      identification: json['identification'],
      locationId: json['location_id'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => Skill.fromJson(e)).toList() ?? [],
    );
  }
}
