import 'dart:convert';

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
    try {
      if (rolDado == 'voluntario') {
        final getUrl = Uri.parse('http://localhost:5170/api/v1/volunteers/$id');
        final getResponse = await http.get(getUrl);

        if (getResponse.statusCode == 200) {
          final existingData = jsonDecode(getResponse.body);

          updateIfNotEmpty(existingData, 'email', correoController.text);
          updateIfNotEmpty(existingData, 'password', passwordController.text);
          updateIfNotEmpty(existingData, 'name', nombreController.text);
          updateIfNotEmpty(existingData, 'surname', apellidosController.text);
          updateIfNotEmpty(existingData, 'birthDate', fechaNacimientoController.text);
          updateIfNotEmpty(existingData, 'phone_number', telefonoController.text);

          print(existingData);

          final putUrl = Uri.parse('http://localhost:5170/api/v1/volunteers/$id');
          final putResponse = await http.put(
            putUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(existingData),
          );

          if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Perfil modificado correctamente')),
            );
            Navigator.pushReplacementNamed(context, '/homeScreenVoluntario');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al modificar perfil')),
            );
            print(putResponse.statusCode);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener datos actuales del voluntario')),
          );
        }
      }

      if (rolDado == 'victima') {
        final getUrl = Uri.parse('http://localhost:5170/api/v1/victims/$id');
        final getResponse = await http.get(getUrl);

        if (getResponse.statusCode == 200) {
          final existingData = jsonDecode(getResponse.body);

          updateIfNotEmpty(existingData, 'email', correoController.text);
          updateIfNotEmpty(existingData, 'password', passwordController.text);
          updateIfNotEmpty(existingData, 'name', nombreController.text);
          updateIfNotEmpty(existingData, 'surname', apellidosController.text);
          updateIfNotEmpty(existingData, 'birthDate', fechaNacimientoController.text);
          updateIfNotEmpty(existingData, 'phone', telefonoController.text);


          final putUrl = Uri.parse('http://localhost:5170/api/v1/victims/$id');
          final putResponse = await http.put(
            putUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(existingData),
          );

          if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Perfil modificado correctamente')),
            );
            Navigator.pushReplacementNamed(context, '/homeScreenAfectado');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al modificar perfil')),
            );
            print(putResponse.statusCode);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener datos actuales del voluntario')),
          );
        }
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
  void updateIfNotEmpty(Map<String, dynamic> data, String key, String value) {
    if (value != null && value.trim().isNotEmpty) {
      data[key] = value.trim();
    }
  }
}