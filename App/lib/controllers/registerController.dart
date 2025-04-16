import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '/interface/registerChoose.dart';
import '../services/auth_service.dart';

class RegisterController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final UserRegistrationData userData;

  RegisterController(this.userData);

  bool validatePasswords() {
    return passwordController.text == repeatPasswordController.text;
  }


  void register(BuildContext context) async{
    try {
      if (AuthService.emailExists(emailController.text.trim()) != true) {
        print("Datos de login guardados en el modelo:");
        print("Continua Registro");
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => RegisterChoose(userData),),);
      }
      else {
        print("El Email introducido ya existe");
      }
    }
    catch(e) {
      print("Error de conexión con el servidor: $e");
    }
      if(validatePasswords() && emailController.text.isNotEmpty) {
        userData.email = emailController.text.trim();
        userData.password = passwordController.text;
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

}


