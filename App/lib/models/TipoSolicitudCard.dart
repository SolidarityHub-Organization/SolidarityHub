import 'package:flutter/material.dart';
import 'TipoSolicitud.dart';

class TipoSolicitudCard extends StatelessWidget {
  final TipoSolicitud tipo;
  final VoidCallback? onCancelar;
  final VoidCallback? onCompletar;

  const TipoSolicitudCard({
    required this.tipo,
    this.onCancelar,
    this.onCompletar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con avatar
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Text(
                  tipo.name.isNotEmpty ? tipo.name[0].toUpperCase() : '',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(tipo.address),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),
          Text("Cantidad: X"),
          Text("Estado: ${tipo.status.isNotEmpty ? tipo.status : 'Pendiente'}"),
          Text("Teléfono: teléfono"),
          Text("Descripción:"),
          Text(
            tipo.description,
            style: TextStyle(color: Colors.grey[700]),
          ),

          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 4),

          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancelar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    "CANCELAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCompletar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    "COMPLETAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
