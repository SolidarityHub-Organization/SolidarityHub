import 'package:flutter/material.dart';
import './task_post.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    print('Tarea: ${task.name} - Horarios recibidos: ${task.times.length}');
    for (var t in task.times) {
      print('  → ${t.date} ${t.startTime} - ${t.endTime}');
    }

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
                child: Text('A', style: const TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Coordenadas: ${task.latitude}, ${task.longitude}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Horarios:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ...task.times.map((time) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${time.date} — ${time.startTime} a ${time.endTime}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    )),
                    Text('Descripción:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.description,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}