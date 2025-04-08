import 'package:app/interface/pantallaInicio.dart';
import 'package:flutter/material.dart';
import 'interface/loginUI.dart'; // Importamos la pantalla de login
import 'interface/register.dart';
import 'interface/registerChoose.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug"
      title: 'Solidary Hub',
      theme: ThemeData(
        primarySwatch: Colors.red, // Color principal de la app
      ),
      initialRoute: '/inicio',
      routes: {
        '/inicio': (context) => SplashScreen(), // Pantalla principal
        '/login': (context) => loginUI(), // Ruta nombrada para LogIn
        '/register': (context) => Register(), // Ruta nombrada para registro
        '/registerChoose': (context) => RegisterChoose(), // Ruta nombrada para registro especifico
      }
    );
  }
}