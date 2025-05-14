import 'package:flutter/material.dart';
import '../controllers/loginAUTH.dart';
import '../models/button_creator.dart';
import '../models/custom_form_builder.dart';
import '../services/login_validators.dart';

class loginUI extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginUI> {
  final AuthController authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      authController.login(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // Fondo rojo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100), // Logo superior
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white, // Tarjeta blanca central
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomFormBuilder(
                formKey: _formKey,
                children: [
                  // Botones de Login y Registro
                  Row(
                    children: [
                      Expanded(
                        child: buildCustomButton(
                          "Log In",
                              () => authController.onLoginTabPressed(context),
                          verticalPadding: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildCustomButton(
                          "Registro",
                              () => authController.onRegisterTabPressed(context),
                          backgroundColor: Colors.red.shade200,
                          verticalPadding: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Texto de bienvenida
                  Text(
                    'Bienvenido a Solidarity Hub',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Campo de email
                  TextFormField(
                    controller: authController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: validateEmail,
                  ),
                  SizedBox(height: 15),

                  // Campo de contraseña
                  TextFormField(
                    controller: authController.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: validatePassword,
                  ),

                  SizedBox(height: 10),

                  // Enlace de "¿Has olvidado la contraseña?"
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '¿Has olvidado la contraseña?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Botón de "Log in"
                  buildCustomButton(
                    "Log in",
                    _validateAndLogin,
                    verticalPadding: 15,
                    horizontalPadding: 100,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
