import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../models/user_registration_data.dart';

class RegisterController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final UserRegistrationData userData;

  RegisterController(this.userData);

  bool validatePasswords() {
    return passwordController.text == repeatPasswordController.text;
  }

  void register() {
    userData.email = emailController.text.trim();
    userData.password = passwordController.text;

    print("Datos de login guardados en el modelo:");
    print(userData.toJson());
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


