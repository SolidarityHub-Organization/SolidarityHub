import 'package:app/interface/notificationScreen.dart';
import 'package:app/interface/taskListScreen.dart';
import 'package:flutter/material.dart';
import 'ajustes.dart';
import '../controllers/homeScreenController.dart';
import '../models/button_creator.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

class HomeScreenVoluntario extends StatefulWidget {
  final String userName;
  final int id;
  final String role;

  const HomeScreenVoluntario({
    super.key,
    required this.id,
    required this.userName,
    required this.role,
  });

  @override
  State<HomeScreenVoluntario> createState() => _HomeScreenVoluntarioState();
}

class _HomeScreenVoluntarioState extends State<HomeScreenVoluntario> {
  final HomeScreenController homeScreenController = HomeScreenController();
  int newNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notifications =
      await NotificationService.fetchNotifications(widget.id);
      setState(() {
        newNotificationCount = notifications.length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                hoverColor: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.logout, color: Colors.white, size: 28),
              ),
            ),

            // Botón de notificaciones con badge
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: Stack(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NotificationScreen(id: widget.id),
                          ),
                        ).then((_) => _loadNotificationCount());
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        backgroundColor: Colors.red,
                        elevation: 4,
                        shadowColor: Colors.black26,
                      ),
                      child: const Icon(Icons.mail_outline,
                          color: Colors.white, size: 24),
                    ),
                    if (newNotificationCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            newNotificationCount > 9 ? '9+' : '$newNotificationCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "BIENVENIDO ${widget.userName}".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Eres un voluntario",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver tareas inscritas",
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskListScreen(id: widget.id),
                          ),
                        ),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.newspaper, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver tareas disponibles",
                        homeScreenController.onVerTareasPressed(
                            context, widget.id),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver necesidades",
                        homeScreenController.onNecesidadesPressed(context),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon:
                        const Icon(Icons.help_center, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ajustes",
                        homeScreenController.onSettingsPressed(
                            context, widget.id, widget.role),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Cerrar sesión",
                        homeScreenController.onCerrarSesionPressed(context),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
