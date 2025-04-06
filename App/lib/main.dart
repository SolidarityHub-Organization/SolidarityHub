import 'package:flutter/material.dart';
import 'interface/loginUI.dart'; // Importamos la pantalla de login
import 'interface/register.dart';

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
      //home: Register(), // Inicia la app con la pantalla de login
      home: loginUI(), // Inicia la app con la pantalla de login

    );
  }
}