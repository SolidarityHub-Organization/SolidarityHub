class RegisterValidator {
  static String? validateEmail(String email) {
    if (email.isEmpty) return 'El email no puede estar vacío';
    if (!email.contains('@')) return 'Introduce un email válido';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'La contraseña no puede estar vacía';
    if (password.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  static String? validateRepeatPassword(String password, String repeatPassword) {
    if (repeatPassword.isEmpty) return 'Repite la contraseña';
    if (password != repeatPassword) return 'Las contraseñas no coinciden';
    return null;
  }
}