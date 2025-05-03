String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'El email no puede estar vacío';
  if (!value.contains('@')) return 'Introduce un email válido';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía';
  return null;
}