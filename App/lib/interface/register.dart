import 'package:app/interface/registerChoose.dart';
import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../controllers/registerController.dart';
import '../models/button_creator.dart';
import '../services/register_validator.dart';

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

  void _saveState(){
    manager.userData.email = registerController.emailController.text.trim();
    manager.userData.password = registerController.passwordController.text;
    manager.saveStep();
  }

  void _register() async {
    final email = registerController.emailController.text.trim();
    final password = registerController.passwordController.text;
    final repeatPassword = registerController.repeatPasswordController.text;

    setState(() {
      _emailErrorText = RegisterValidator.validateEmail(email);
      _passwordErrorText = RegisterValidator.validatePassword(password);
      _repeatPasswordErrorText = RegisterValidator.validateRepeatPassword(password, repeatPassword);

      _emailHasError = _emailErrorText != null;
      _passwordHasError = _passwordErrorText != null;
      _repeatPasswordHasError = _repeatPasswordErrorText != null;
    });

    final isValid = !_emailHasError && !_passwordHasError && !_repeatPasswordHasError;

    if (isValid) {
      final success = await registerController.register();

      if (!success) {
        _saveState();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterChoose(manager)),
        );
      } else {
        setState(() {
          _emailHasError = true;
          _emailErrorText = 'Este correo ya está registrado';
        });
      }
    }
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
                        child: buildCustomButton(
                          "Registro",
                          () => registerController.onRegisterTabPressed(context),
                          verticalPadding: 12,
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
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
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
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
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
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
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