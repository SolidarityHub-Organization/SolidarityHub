import 'package:flutter/material.dart';
import '../models/task_post.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Fila con avatar + texto
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEBDDFB),
                radius: 20,
                child: Text(
                  "A",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),

              /// Nombre + Localización
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<Location>(
                    future: LocationService.fetchLocation(task.locationId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Cargando zona...", style: TextStyle(color: Colors.grey));
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Text("Zona desconocida", style: TextStyle(color: Colors.red));
                      } else {
                        return Text(
                          snapshot.data!.name,
                          style: const TextStyle(color: Colors.grey),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Imagen de ejemplo
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 12),

          /// Botón de estado alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Text(
                'Asignada',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}