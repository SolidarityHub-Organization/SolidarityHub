class Recurso {
  final int id;
  final String name;

  Recurso({required this.id, required this.name});

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'],
      name: json['name'],
    );
  }
}