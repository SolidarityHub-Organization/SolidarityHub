import 'package:flutter/material.dart';
import '../controllers/loginAUTH.dart'; // Importamos el controlador

class loginUI extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginUI> {
  final AuthController authController = AuthController(); // Instancia del controlador

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
                  TextField(
                    controller: authController.emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: authController.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                  ),

                  SizedBox(height: 10),
                  // Enlace de "¿Has olvidado la contraseña?"
                  TextButton(
                    onPressed: () {},
                    child: Text('Has olvidado la contraseña?', style: TextStyle(color: Colors.black)),
                  ),

                  SizedBox(height: 20),
                  // Botón de "Log in"
                  ElevatedButton(
                    onPressed: authController.login, // Llamamos al método login() del controlador
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
