import 'package:flutter/material.dart';

class RegisterChooseController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void submitForm(String role) {
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
  }

  bool _isValidPhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }
}
