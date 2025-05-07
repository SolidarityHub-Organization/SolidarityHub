import 'package:flutter/material.dart';
import '../interface/dataModification.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dialogs.dart';

class SettingsController {

  VoidCallback onDataModificationPressed(BuildContext context, int id,
      String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => DataModification(id: id, role: role),),
      );
    };
  }

    Future<void> onDeleteAccountPressed(BuildContext context, int id, String role) async {
      await showDeleteConfirmationDialog(context, () async {

        if(role == 'voluntario'){
          final url = Uri.parse('http://localhost:5170/api/v1/volunteers/$id');
          final response = await http.delete(
            url,
            headers: {'Content-Type': 'application/json'},
          );
          if (response.statusCode == 200 || response.statusCode == 204) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cuenta eliminada correctamente')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            print('${response.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar cuenta')),
            );
          }
        }

        else if(role == 'afectado'){
          final url = Uri.parse('http://localhost:5170/api/v1/victims/$id');
          final response = await http.delete(
            url,
            headers: {'Content-Type': 'application/json'},
          );
          if (response.statusCode == 200 || response.statusCode == 204) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cuenta eliminada correctamente')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            print('${response.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar cuenta')),
            );
          }
        }

      });
    }
  }