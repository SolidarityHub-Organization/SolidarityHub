import 'package:flutter/material.dart';
import './task_post.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Text(
                  'A',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('Coordenadas de la ubicación: ${task.latitude}, ${task.longitude}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text('Horario de la tarea:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}