import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../services/auth_service.dart';
import '../interface/schedules.dart';
import '../interface/addressScreen.dart';
import 'dart:convert';

class RegisterChooseController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController identificationController = TextEditingController();
  String? selectedRole;
  final RegisterFlowManager manager;

  RegisterChooseController(this.manager);



  void submitForm(String role, BuildContext context) async {
    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String birthDate = birthDateController.text.trim();
    String phone = phoneController.text.trim();
    String identification = identificationController.text.trim();

    if (name.isEmpty || surname.isEmpty || birthDate.isEmpty || phone.isEmpty || identification.isEmpty) {
      print('Por favor, completa todos los campos.');
      return;
    }

    if (!isValidPhone(phone)) {
      print('El número de teléfono no es válido.');
      return;
    }

    print('Nombre: $name');
    print('Apellidos: $surname');
    print('Fecha de nacimiento: $birthDate');
    print('Teléfono: $phone');
    print('Rol seleccionado: $role');
    print('DNI: $identification');

    manager.userData.name = nameController.text.trim();
    manager.userData.surname = surnameController.text.trim();
    manager.userData.birthDate = birthDateController.text.trim();
    manager.userData.phone = phoneController.text.trim();
    manager.userData.identification = identificationController.text.trim();
    manager.userData.role = role;

    print("[RegisterChooseController] Datos personales guardados:");

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(manager: manager),),);

  }
  bool isValidPhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidIdentification(String identification) {
    identification = identification.toUpperCase().trim();

    // Expresión regular para formato correcto
    final dniRegExp = RegExp(r'^\d{8}[A-Z]$');
    if (!dniRegExp.hasMatch(identification)) return false;

    // Letras de control
    const letters = "TRWAGMYFPDXBNJZSQVHLCKE";
    final number = int.parse(identification.substring(0, 8));
    final letter = letters[number % 23];

    return identification[8] == letter;
  }

}
