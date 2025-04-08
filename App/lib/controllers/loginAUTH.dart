import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    print("Email: $email");
    print("Contraseña: $password");

    try {
      final url = Uri.parse('https://tuservidor.com/api/login'); // Cambia esta URL por la real

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

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
