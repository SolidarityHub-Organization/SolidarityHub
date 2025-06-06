String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'El email no puede estar vacío';
  if (!value.contains('@')) return 'Introduce un email válido';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía';
  return null;
}

String? validateWithConfirmPassword(String? value1, String? value2){
  validateIsEmpty(value1);
  validateIsEmpty(value2);
  if(value1 != value2) return 'Las contraseñas no coinciden';
  return null;
}

String? validateIsEmpty(String? value){
  if (value == null || value.isEmpty) return 'Por favor, rellene el campo';
  return null;
}
String? validatePhone(String? value){
  validateIsEmpty(value);
  final RegExp phoneRegex = RegExp(r'^[0-9]{9}$');
  if(!phoneRegex.hasMatch(value!)){
    return 'Introduce un número válido de 9 dígitos';
  }
  return null;
}

String? validatePhoneWithoutEmpty(String? value){
  if (value == null || value.trim().isEmpty) return null;

  final RegExp phoneRegex = RegExp(r'^[0-9]{9}$');
  if (!phoneRegex.hasMatch(value)) {
    return 'Introduce un número válido de 9 dígitos';
  }
  return null;
}


String? validateIdentification(String? value){
  final dniRegExp = RegExp(r'^\d{8}[A-Z]$');
  if(!dniRegExp.hasMatch(value!)){
    return 'Introduce un DNI válido';
  }
  return null;
}

String? validateEmailWithoutEmpty(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!value.contains('@')) return 'Introduce un email válido';
  return null;
}

String? validatePasswordWithoutEmpty(String? value) {
  if (value == null || value.isEmpty) return null;
  if(value.isNotEmpty && value.length < 6) return 'La contraseña debe tener un mínimo de 6 caracteres';
  return null;
}

String? validateConfirmPasswordWithoutEmpty(String? value1, String? value2){
  if(value1 != value2) return 'Las contraseñas no coinciden';
  if(value1!.isNotEmpty && value1.length < 6) return 'La contraseña debe tener un mínimo de 6 caracteres';
  return null;
}