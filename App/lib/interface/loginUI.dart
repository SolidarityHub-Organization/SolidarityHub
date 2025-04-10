import 'package:flutter/material.dart';
import '../controllers/loginAUTH.dart'; // Importamos el controlador

class loginUI extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginUI> {
  final AuthController authController = AuthController(); // Instancia del controlador
  bool _emailHasError = false;
  bool _passwordHasError = false;

  String? _emailErrorText;
  String? _passwordErrorText;

  void _validateAndLogin() {
    setState(() {
      _emailHasError = false;
      _passwordHasError = false;
      _emailErrorText = null;
      _passwordErrorText = null;

      bool isValid = true;
      String email = authController.emailController.text.trim();
      String password = authController.passwordController.text;

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
      }

      if (isValid) {
        authController.login();
      }
    });
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
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white, // Tarjeta blanca central
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botones de Login y Registro
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => authController.onLoginTabPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Log In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => authController.onRegisterTabPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Registro",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Texto de bienvenida
                  Text('Bienvenido a Solidary Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),
                  // Campos de texto
                  // Email
                  TextField(
                    controller: authController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  SizedBox(height: 15),
                  //Contraseña
                  TextField(
                    controller: authController.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      errorText: _passwordErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  // Enlace de "¿Has olvidado la contraseña?"
                  TextButton(
                    onPressed: () {},
                    child: Text('¿Has olvidado la contraseña?', style: TextStyle(color: Colors.black)),
                  ),

                  SizedBox(height: 20),
                  // Botón de "Log in"
                  ElevatedButton(
                    onPressed: _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Log in', style: TextStyle(color: Colors.white, fontSize: 16)),
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


