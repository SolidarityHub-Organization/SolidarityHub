import 'package:app/controllers/settingsController.dart';
import 'package:flutter/material.dart';
import '../models/button_creator.dart';
import '../interface/dataModification.dart';
import '../controllers/settingsController.dart';

class AjustesCuenta extends StatelessWidget {

  final int id;
  final String role;

  SettingsController settingsController = SettingsController();
  AjustesCuenta({required this.id, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado con flecha y título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      hoverColor: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "AJUSTES",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Contenedor blanco con los ajustes
            Expanded(
              child: Center(
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
                      Text(
                        "AJUSTES DE CUENTA",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: buildCustomButton(
                          "Cambiar Datos",
                          settingsController.onDataModificationPressed(context, id, role),
                          verticalPadding: 14,
                          horizontalPadding: 0,
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildButton("Cambiar Horario"),
                      SizedBox(height: 16),
                      _buildButton("Cambiar Preferencias"),
                      SizedBox(height: 16),
                      _buildButton("Cambiar Zona De\nPreferencia"),
                      SizedBox(height: 40),
                      buildCustomButton(
                          "Eliminar cuenta",
                          settingsController.onDeleteAccountPressed(context, id, role),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        minimumSize: Size(double.infinity, 0),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
