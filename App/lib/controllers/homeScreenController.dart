import 'package:app/interface/ajustes.dart';
import 'package:flutter/material.dart';
import '../interface/availableTasks.dart';
import '../interface/solicitud_recursos.dart';

class HomeScreenController {

  VoidCallback onSettingsPressed(BuildContext context, int id, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => AjustesCuenta(id: id, role: role),),
      );
    };
  }

  VoidCallback onVerTareasPressed(BuildContext context, int id) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => AvailableTasksScreen(id: id),),
      );
    };
  }

  VoidCallback onCerrarSesionPressed(BuildContext context) {
    return() {
      Navigator.pushNamed(context, '/login');
    };
  }

  void onVerNotificacionesPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notificationScreen');
  }

  VoidCallback onRecursosPressed(BuildContext context) { //int id, String role
    return () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => SolicitarRecursoPage(),),
      );
    };
  }
}
