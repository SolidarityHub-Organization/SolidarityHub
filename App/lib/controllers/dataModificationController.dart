import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataModificationController {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repetirPasswordController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  static const String baseUrl = 'http://localhost:5170/api/v1';

  Future<void> saveData(BuildContext context, int id, String role) async {
    try {
      String endpoint;
      String phoneKey;
      String redirectRoute;

      if (role == 'voluntario') {
        endpoint = 'volunteers';
        phoneKey = 'phone_number';
        redirectRoute = '/homeScreenVoluntario';
      } else if (role == 'victima') {
        endpoint = 'victims';
        phoneKey = 'phone';
        redirectRoute = '/homeScreenAfectado';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol desconocido: $role')),
        );
        return;
      }

      final getUrl = Uri.parse('$baseUrl/$endpoint/$id');
      final getResponse = await http.get(getUrl);

      if (getResponse.statusCode == 200) {
        final existingData = jsonDecode(getResponse.body);

        updateIfNotEmpty(existingData, 'email', correoController.text);
        updateIfNotEmpty(existingData, 'password', passwordController.text);
        updateIfNotEmpty(existingData, 'name', nombreController.text);
        updateIfNotEmpty(existingData, 'surname', apellidosController.text);
        updateIfNotEmpty(existingData, 'birthDate', fechaNacimientoController.text);
        updateIfNotEmpty(existingData, phoneKey, telefonoController.text);

        final putUrl = Uri.parse('$baseUrl/$endpoint/$id');
        final putResponse = await http.put(
          putUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(existingData),
        );


        if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Perfil modificado correctamente')),
          );
          Navigator.pushReplacementNamed(context, redirectRoute);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al modificar perfil (${putResponse.statusCode})')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron obtener los datos del usuario')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red o inesperado: $e')),
      );
    }
  }

  void updateIfNotEmpty(Map<String, dynamic> data, String key, String value) {
    if (value.trim().isNotEmpty) {
      data[key] = value.trim();
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
