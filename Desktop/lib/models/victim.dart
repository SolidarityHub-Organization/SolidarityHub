class Victim {
  final int id;
  final String email;
  final String name;
  final String surname;
  final int prefix;
  final String phoneNumber;
  final String address;
  final String identification;
  final int locationId;

  Victim({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.prefix,
    required this.phoneNumber,
    required this.address,
    required this.identification,
    required this.locationId,
  });

  factory Victim.fromJson(Map<String, dynamic> json) {
    return Victim(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      prefix: json['prefix'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      identification: json['identification'],
      locationId: json['location_id'],
    );
  }
}
