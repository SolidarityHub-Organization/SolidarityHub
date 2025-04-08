import 'package:flutter/material.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool validatePasswords() {
    return passwordController.text == repeatPasswordController.text;
  }

  void register() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");
    print("Registro exitoso");
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
  }

  void onLogInTabPressed(BuildContext context) {
    print("Pulsado LogIn");
    Navigator.pushNamed(context, '/login');
  }

  void onRegisterTabPressed(BuildContext context) {
    print("Pulsado Register");
    Navigator.pushNamed(context, '/register');
  }

  void continueRegister(BuildContext context) {
    print("Continua Registro");
    Navigator.pushNamed(context, '/registerChoose');
  }
}


