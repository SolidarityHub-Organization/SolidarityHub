import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class VolunteerPreferencesController {
  final UserRegistrationData userData;

  VolunteerPreferencesController(this.userData);

  final Map<String, bool> preferences = {
    'Limpieza': false,
    'Primeros Auxilios': false,
    'Coordinación de ayuda': false,
    'Transporte y movilidad': false,
    'Reparto de comida': false,
    'Cocina y alimentación': false,
    'Acogidas': false,
    'Ayuda Salud Mental': false,
  };

  void togglePreference(String key) {
    preferences[key] = !(preferences[key] ?? false);
  }

  bool isAtLeastOneSelected() {
    return preferences.values.any((value) => value);
  }

  void finalizeRegistration(BuildContext context) async {
    List<String> selected = preferences.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print("Preferencias seleccionadas: $selected");

    userData.preferences = selected.join(', ');

    try {
      final response = await AuthService.registerVolunteer(userData.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Registro exitoso");
        print("Respuesta del servidor: $data");
      } else {
        print("Error en el registro: ${response.statusCode}");
        print("Mensaje: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con el servidor: $e");
    }

    print("[RegisterChooseController] Datos personales guardados:");
    print(userData.toJson());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registro finalizado con éxito.")),
    );
  }
}