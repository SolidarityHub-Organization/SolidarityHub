import 'package:app/interface/notificationScreen.dart';
import 'package:app/interface/taskListScreen.dart';
import 'package:flutter/material.dart';
import 'ajustes.dart';
import '../controllers/homeScreenController.dart';
import '../models/button_creator.dart';

class HomeScreenVoluntario extends StatelessWidget {
  final String userName;
  final int id;
  final String role;
  final HomeScreenController homeScreenController = HomeScreenController();

  HomeScreenVoluntario({
    required this.id,
    required this.userName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón de logout (esquina superior izquierda)
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                hoverColor: Colors.white.withOpacity(0.1),
                child: Icon(Icons.logout, color: Colors.white, size: 28),
              ),
            ),

            // Botón de notificaciones (esquina superior derecha)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(id: id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.red,
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child: const Icon(Icons.mail_outline, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Contenedor principal centrado
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "BIENVENIDO $userName".toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Eres un voluntario",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver tareas inscritas",
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskListScreen(id: id),
                          ),
                        ),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.newspaper, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver tareas disponibles",
                        homeScreenController.onVerTareasPressed(context, id),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ver necesidades",
                        homeScreenController.onNecesidadesPressed(context),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.help_center, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Ajustes",
                        homeScreenController.onSettingsPressed(context, id, role),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: buildCustomButton(
                        "Cerrar sesión",
                        homeScreenController.onCerrarSesionPressed(context),
                        verticalPadding: 14,
                        horizontalPadding: 0,
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.logout, color: Colors.white),
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
