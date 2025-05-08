import 'package:app/interface/ajustes.dart';
import 'package:flutter/material.dart';

class HomeScreenController {

  VoidCallback onSettingsPressed(BuildContext context, int id, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => AjustesCuenta(id: id, role: role),),
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

  void onVerNotificacionesPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notificationScreen');
  }
}
