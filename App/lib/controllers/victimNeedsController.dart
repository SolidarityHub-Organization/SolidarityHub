import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:app/interface/loginUI.dart';

class VictimNeedsController {
  final UserRegistrationData userData;

  VictimNeedsController(this.userData);

  final Map<String, bool> needs = {
    'Comida': true,
    'Productos farmacéuticos': true,
    'Limpieza': true,
    'Transporte y movilidad': true,
    'Apoyo psicológico': true,
    'Acogida': true,
    'Necesidades especiales': true,
    'Ropa': true,
    'Higiene Personal': true,
  };

  void toggleNeed(String key) {
    needs[key] = !(needs[key] ?? false);
  }

  bool isAtLeastOneSelected() {
    return needs.values.any((value) => value);
  }

  void finalizeRegistration(BuildContext context) async {
    List<String> selected = needs.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print("Necesidades seleccionadas: $selected");

    userData.needs = selected.join(', ');

    try {
      final response = await AuthService.registerVictims(userData.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Registro exitoso");
        print("Respuesta del servidor: $data");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginUI()),);
      } else {
        print("Error en el registro: ${response.statusCode}");
        print("Mensaje: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con el servidor: $e");
    }

    print("[VictimNeedsController] Datos personales guardados:");
    print(userData.toJson());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registro finalizado con éxito.")),
    );
  }
}
