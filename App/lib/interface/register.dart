import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../controllers/registerController.dart';
import '../models/user_registration_data.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late RegisterFlowManager manager;
  late RegisterController registerController;
  bool _showError = false;
  bool _emailHasError = false;
  bool _passwordHasError = false;
  bool _repeatPasswordHasError = false;

  String? _emailErrorText;
  String? _passwordErrorText;
  String? _repeatPasswordErrorText;

  @override
  void initState() {
    super.initState();
    manager = RegisterFlowManager();
    registerController = RegisterController(manager);
  }

  @override
  void dispose() {
    registerController.dispose();
    super.dispose();
  }

  void _register() {
    setState(() {
      // Resetear errores
      _emailHasError = false;
      _passwordHasError = false;
      _repeatPasswordHasError = false;

      _emailErrorText = null;
      _passwordErrorText = null;
      _repeatPasswordErrorText = null;

      bool isValid = true;

      String email = registerController.emailController.text.trim();
      String password = registerController.passwordController.text;
      String repeatPassword = registerController.repeatPasswordController.text;

      if (email.isEmpty) {
        _emailHasError = true;
        _emailErrorText = 'El email no puede estar vacío';
        isValid = false;
      } else if (!email.contains('@')) {
        _emailHasError = true;
        _emailErrorText = 'Introduce un email válido';
        isValid = false;
      }

      if (password.isEmpty) {
        _passwordHasError = true;
        _passwordErrorText = 'La contraseña no puede estar vacía';
        isValid = false;
      } else if (password.length < 6) {
        _passwordHasError = true;
        _passwordErrorText = 'Debe tener al menos 6 caracteres';
        isValid = false;
      }

      if (repeatPassword.isEmpty) {
        _repeatPasswordHasError = true;
        _repeatPasswordErrorText = 'Repite la contraseña';
        isValid = false;
      } else if (password != repeatPassword) {
        _repeatPasswordHasError = true;
        _repeatPasswordErrorText = 'Las contraseñas no coinciden';
        isValid = false;
      }

      if (isValid) {
        registerController.register(context);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100), // Logo superior
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => registerController.onLogInTabPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Log In", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => registerController.onRegisterTabPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Registro", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  const Text(
                    "Bienvenido a Solidarity Hub",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: registerController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email*',
                      errorText: _emailErrorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _emailHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _emailHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: registerController.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña*',
                      errorText: _passwordErrorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _passwordHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _passwordHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: registerController.repeatPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Repite Contraseña*',
                      errorText: _repeatPasswordErrorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _repeatPasswordHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _repeatPasswordHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Registro', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}