import 'package:app/interface/ajustes.dart';
import 'package:flutter/material.dart';

class HomeScreenController {

  VoidCallback onSettingsPressed(BuildContext context, String email, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => AjustesCuenta(email: email, role: role),),
      );
    };
  }

  void onVerTareasPressed(BuildContext context) {
    Navigator.pushNamed(context, '/tareas');
  }

  VoidCallback onCerrarSesionPressed(BuildContext context) {
    return() {
      Navigator.pushNamed(context, '/login');
    };
  }
}
