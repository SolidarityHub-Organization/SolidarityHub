import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '/interface/homeScreen.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");

    try {
      final response = await AuthService.login(email, password); // Llamada al servicio

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login exitoso');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()),);
        print('Token recibido: ${data['token']}');
      } else {
        print('Error de login: ${response.statusCode}');
        print('Mensaje: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión con el servidor: $e');
    }
  }

  void onLoginTabPressed(BuildContext context) {
    print("Pulsado Log In");
    Navigator.pushNamed(context, '/login');
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
