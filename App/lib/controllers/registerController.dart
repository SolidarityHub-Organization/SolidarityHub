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
    userData.email = emailController.text.trim();
    userData.password = passwordController.text;

    print("Datos de login guardados en el modelo:");
    print("Continua Registro");
    Navigator.push(context, MaterialPageRoute( builder: (context) => RegisterChoose(userData),),);
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

/*  void continueRegister(BuildContext context) {

    userData.email = emailController.text;
    userData.password = passwordController.text;

  }
  */
}


