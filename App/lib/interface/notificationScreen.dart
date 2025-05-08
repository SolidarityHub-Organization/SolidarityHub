import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../models/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  final int id;

  const NotificationScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: NotificationService.fetchUserNotifications(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else {
            final notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return const Center(child: Text("No tienes notificaciones.", style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(notification: notifications[index]);
              },
            );
          }
        },
      ),
    );
  }
}
