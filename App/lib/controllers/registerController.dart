import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool validatePasswords() {
    return passwordController.text == repeatPasswordController.text;
  }

  void register() async{
    final email = emailController.text.trim();
    final password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");
    try {
      final response = await AuthService.register(email, password); // Llamada al servicio

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login exitoso');
        print('Token recibido: ${data['token']}');
      } else {
        print('Error de login: ${response.statusCode}');
        print('Mensaje: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión con el servidor: $e');
    }
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


