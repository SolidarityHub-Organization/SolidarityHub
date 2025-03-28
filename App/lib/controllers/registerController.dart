import 'package:flutter/material.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void Register() {
    String email = emailController.text;
    String password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");

    // Aquí puedes añadir validaciones o conectar con Firebase o un backend
  }
}
