import 'package:flutter/material.dart';
import 'ajustes.dart';
import '../controllers/homeScreenController.dart';
import '../models/button_creator.dart';

class HomeScreenVoluntario extends StatelessWidget {
  final String userName;
  final String email;
  final HomeScreenController homeScreenController = HomeScreenController();
  HomeScreenVoluntario({required this.email, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Stack(
          children: [
            // Icono superior izquierdo
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login'); // O la ruta que corresponda
                },
                hoverColor: Colors.white.withOpacity(0.1),
                child: Icon(Icons.logout, color: Colors.white, size: 28),
              ),
            ),


            // Contenedor blanco centrado
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    Column(
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
                        buildButton("Ver tareas inscritas"),
                        SizedBox(height: 16),
                        buildButton("Ver tareas disponibles"),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: buildCustomButton(
                            "Ajustes",
                            homeScreenController.onSettingsPressed(context, email),
                            verticalPadding: 14,
                            horizontalPadding: 0,
                            backgroundColor: Colors.red,
                          ),
                        ),

                        SizedBox(height: 40),

                        // Botón separado
                        SizedBox(
                          width: double.infinity,
                          child: buildCustomButton(
                            "Cerrar sesión",
                            homeScreenController.onCerrarSesionPressed(context),
                            verticalPadding: 14,
                            horizontalPadding: 0,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    // Icono de mensaje
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.mail_outline, color: Colors.white),
                        ),
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
