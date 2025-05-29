
import 'dart:convert';

import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final RegisterFlowManager manager;

  RegisterController(this.manager);

  bool validatePasswords() {
    return passwordController.text == repeatPasswordController.text;
  }

  Future<bool> register() async {
    try {
      final email = emailController.text.trim();
      final exists = await AuthService.emailExists(email);

      if (exists) {
        return false;
      }

      if (validatePasswords() && email.isNotEmpty) {
        manager.userData.email = email;
        manager.userData.password = passwordController.text;
        return true;
      }
    } catch (e) {
      print("Error de conexión con el servidor: \$e");
    }
    return false;
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


}
