import 'package:app/interface/ajustes.dart';
import 'package:app/interface/availableTasks.dart';
import 'package:app/interface/dataModification.dart';
import 'package:app/interface/homeScreenVoluntario.dart';
import 'package:app/interface/logoScreen.dart';
import 'package:app/interface/taskListScreen.dart';
import 'package:flutter/material.dart';
import 'interface/homeScreenAfectado.dart';
import 'interface/loginUI.dart';
import 'interface/notificationScreen.dart';
import 'interface/register.dart';
import 'interface/registerChoose.dart';
import 'interface/solicitud_recursos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  int id = 122;
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
        '/homeScreenVoluntario': (context) => HomeScreenVoluntario(id: id, userName: userName, role: role),
        '/homeScreenAfectado': (context) => HomeScreenAfectado(id: id, userName: userName, role: role),
        '/ajustes': (context) => AjustesCuenta(id:id, role: role),
        '/dataModification': (context) => DataModification(id:id, role: role),
        '/taskListScreen': (context) => TaskListScreen(id: id),
        '/notificationScreen': (context) => NotificationScreen(id: id),
        '/availableTasksScreen': (context) => AvailableTasksScreen(id: id),
        '/solicitud_recursos': (context) => SolicitarRecursoPage(),
      }
    );
  }
}