import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class RegisterChooseController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedRole;

  final UserRegistrationData userData;

  RegisterChooseController(this.userData);

  void submitForm(String role) async {
    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String birthDate = birthDateController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty || surname.isEmpty || birthDate.isEmpty || phone.isEmpty) {
      print('Por favor, completa todos los campos.');
      return;
    }

    if (!_isValidPhone(phone)) {
      print('El número de teléfono no es válido.');
      return;
    }

    print('Nombre: $name');
    print('Apellidos: $surname');
    print('Fecha de nacimiento: $birthDate');
    print('Teléfono: $phone');
    print('Rol seleccionado: $role');

    userData.name = nameController.text.trim();
    userData.surname = surnameController.text.trim();
    userData.birthDate = birthDateController.text.trim();
    userData.phone = phoneController.text.trim();
    userData.role = role;

    print("[RegisterChooseController] Datos personales guardados:");
    print(userData.toJson());

    try {
      final response = await AuthService.register(userData.toJson());

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

  }

  bool _isValidPhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }
}
