import 'package:flutter/material.dart';
import '../models/solicitud.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onCancelar;
  final VoidCallback onCompletar;

  const SolicitudCard({
    required this.solicitud,
    required this.onCancelar,
    required this.onCompletar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                solicitud.nombre[0],
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(solicitud.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.localizacion),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Text("Cantidad: ${solicitud.cantidad}"),
        Text("Estado: ${solicitud.estado}"),
        //Text("Teléfono: ${solicitud.telefono}"),
        Text("Descripción:"),
        Text(
          solicitud.descripcion,
          style: TextStyle(color: Colors.grey[700]),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onCancelar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("CANCELAR"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onCompletar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("COMPLETAR"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}