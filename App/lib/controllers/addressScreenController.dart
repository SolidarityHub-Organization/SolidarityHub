import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';

class AddressController {
  final UserRegistrationData userData;

  AddressController(this.userData);

  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  void dispose() {
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
  }

  bool validateFields() {
    return addressLine1Controller.text.isNotEmpty &&
        countryController.text.isNotEmpty &&
        provinceController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        postalCodeController.text.isNotEmpty;
  }

  Map<String, String> getAddressData() {
    return {
      'linea_direccion_1': addressLine1Controller.text,
      'linea_direccion_2': addressLine2Controller.text,
      'pais': countryController.text,
      'provincia': provinceController.text,
      'localidad': cityController.text,
      'codigo_postal': postalCodeController.text,
    };
  }

  String getFullAddressString() {
    final parts = [
      addressLine1Controller.text,
      addressLine2Controller.text,
      cityController.text,
      provinceController.text,
      postalCodeController.text,
      countryController.text,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  void submitAddress() {
    if (validateFields()) {
      final fullAddress = getFullAddressString();
      print('Dirección completa: $fullAddress');
      userData.address = fullAddress;
    } else {
      print('Por favor, completa todos los campos obligatorios');
    }
  }
}
