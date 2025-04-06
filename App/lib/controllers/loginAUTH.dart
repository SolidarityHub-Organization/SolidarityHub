import 'package:flutter/material.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    String email = emailController.text;
    String password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");
  }
    // Aquí puedes añadir validaciones o conectar con Firebase o un backend

  void onLoginTabPressed(BuildContext context) {
    print("Pulsado Log In");
    Navigator.pushNamed(context, '/');
  }

  void onRegisterTabPressed(BuildContext context) {
    print("Pulsado Registro");
    Navigator.pushNamed(context, '/register');
  }

  void onForgotPasswordPressed(BuildContext context) {
    print("Pulsado '¿Has olvidado la contraseña?'");
    // Navigator.pushNamed(context, '/recover');
  }
}