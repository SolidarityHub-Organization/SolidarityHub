import 'package:app/interface/ajustes.dart';
import 'package:app/interface/dataModification.dart';
import 'package:app/interface/homeScreenVoluntario.dart';
import 'package:app/interface/logoScreen.dart';
import 'package:flutter/material.dart';
import 'interface/homeScreenAfectado.dart';
import 'interface/loginUI.dart';
import 'interface/register.dart';
import 'interface/registerChoose.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  String email = "example@email.com";
  String userName = "ExampleName";
  String role = 'example';
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
        //'/registerChoose': (context) => RegisterChoose(), // Ruta nombrada para registro especifico
        '/homeScreenVoluntario': (context) => HomeScreenVoluntario(email: email, userName: userName, role: role),
        '/homeScreenAfectado': (context) => HomeScreenAfectado(email: email, userName: userName, role: role),
        '/ajustes': (context) => AjustesCuenta(email:email, role: role),
        '/dataModification': (context) => DataModification(email:email, role: role),
      }
    );
  }
}