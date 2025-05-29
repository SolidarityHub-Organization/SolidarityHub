import 'package:flutter/material.dart';
import '../models/necesidad.dart';

class NecesidadCard extends StatelessWidget {
  final Necesidad necesidad;

  const NecesidadCard({required this.necesidad});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              necesidad.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 6),

            // Descripción
            Text("Descripción: ${necesidad.description}"),
            SizedBox(height: 6),

            // Dirección
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16),
                SizedBox(width: 4),
                Text(necesidad.address),
              ],
            ),
            SizedBox(height: 6),

            // Datos de la víctima
            Text("Solicitado por: ${necesidad.victimName}"),
            Text("Teléfono: ${necesidad.victimPhoneNumber}"),
          ],
        ),
      ),
    );
  }
}