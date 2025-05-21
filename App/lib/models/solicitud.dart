class Solicitud {
  final int id;
  final String nombre;
  final String localizacion;
  final int cantidad;
  final String estado;
  //final String telefono;
  final String descripcion;

  Solicitud({
    required this.id,
    required this.nombre,
    required this.localizacion,
    required this.cantidad,
    required this.estado,
    //required this.telefono,
    required this.descripcion,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'],
      nombre: json['nombre'],
      localizacion: json['localizacion'],
      cantidad: json['cantidad'],
      estado: json['estado'],
      //telefono: json['telefono'],
      descripcion: json['descripcion'],
    );
  }
}