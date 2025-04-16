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

  final UserRegistrationData userData;

  RegisterChooseController(this.userData);



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

    userData.name = nameController.text.trim();
    userData.surname = surnameController.text.trim();
    userData.birthDate = birthDateController.text.trim();
    userData.phone = phoneController.text.trim();
    userData.identification = identificationController.text.trim();
    userData.role = role;

    print("[RegisterChooseController] Datos personales guardados:");

    /*if (role.toLowerCase() == "voluntario") {
      Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => Schedules(userData: userData),),);
    }
    else if(role.toLowerCase() == "afectado"){
      Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => AddressScreen(userData: userData),),);
    }
    */
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(userData: userData),),);

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
