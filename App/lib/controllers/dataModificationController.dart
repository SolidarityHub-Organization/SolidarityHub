import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/user_registration_data.dart';

class DataModificationController {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repetirPasswordController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  Future<void> saveData(BuildContext context, int id, String rolDado) async {

    final data = UserRegistrationData()
      ..email = correoController.text
      ..password = passwordController.text
      ..name = nombreController.text
      ..surname = apellidosController.text
      ..birthDate = fechaNacimientoController.text
      ..phone = telefonoController.text
      ..role = rolDado;

    try {
      http.Response response;
      if (rolDado == 'voluntario') {
        response = await AuthService.registerVolunteer(data.toJson());
      } else {
        response = await AuthService.registerVictims(data.toJson());
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos actualizados correctamente')),
        );
        Navigator.pushNamed(context, '/ajustes');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    }
  }

  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    passwordController.dispose();
    repetirPasswordController.dispose();
    fechaNacimientoController.dispose();
    telefonoController.dispose();
  }
}