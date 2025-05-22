class TipoSolicitud {
  final int id;
  final String name;
  final String description;
  final String address;
  final String status;

  TipoSolicitud({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.status,
  });

  factory TipoSolicitud.fromJson(Map<String, dynamic> json) {
    return TipoSolicitud(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      status: json['status'] ?? '',
    );
  }
}
