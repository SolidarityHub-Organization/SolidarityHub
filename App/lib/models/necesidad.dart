class Necesidad {
  final int id;
  final String name;
  final String description;
  final String address;
  final String victimName;
  final String victimPhoneNumber;

  Necesidad({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.victimName,
    required this.victimPhoneNumber,
  });

  factory Necesidad.fromJson(Map<String, dynamic> json) {
    return Necesidad(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      victimName: json['victim_name'],
      victimPhoneNumber: json['victim_phone_number'],
    );
  }
}
