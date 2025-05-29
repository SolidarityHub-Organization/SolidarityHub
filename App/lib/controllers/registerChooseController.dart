import 'package:app/interface/addressScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/register_flow_manager.dart';

class RegisterChooseController {
  final RegisterFlowManager manager;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _identificationController = TextEditingController();

  RegisterChooseController(this.manager) {
    name = manager.userData.name ?? '';
    surname = manager.userData.surname ?? '';
    birthDate = manager.userData.birthDate ?? '';
    phone = manager.userData.phone ?? '';
    identification = manager.userData.identification ?? '';
  }

  String get name => _nameController.text;
  set name(String value) => _nameController.text = value;
  TextEditingController get nameController => _nameController;

  String get surname => _surnameController.text;
  set surname(String value) => _surnameController.text = value;
  TextEditingController get surnameController => _surnameController;

  String get birthDate => _birthDateController.text;
  set birthDate(String value) => _birthDateController.text = value;
  TextEditingController get birthDateController => _birthDateController;

  String get phone => _phoneController.text;
  set phone(String value) => _phoneController.text = value;
  TextEditingController get phoneController => _phoneController;

  String get identification => _identificationController.text;
  set identification(String value) => _identificationController.text = value;
  TextEditingController get identificationController => _identificationController;

  void submitForm(String role, BuildContext context) {
    manager.userData.role = role;
    saveState();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(manager: manager),
      ),
    );

  }

  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _identificationController.dispose();
  }
  

  void saveState() {
    manager.userData.name = name;
    manager.userData.surname = surname;
    manager.userData.birthDate = birthDate;
    manager.userData.phone = phone;
    manager.userData.identification = identification;
    manager.saveStep();
  }

}
