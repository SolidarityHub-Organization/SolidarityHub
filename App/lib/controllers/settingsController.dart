import 'package:flutter/material.dart';
import '../interface/dataModification.dart';

class SettingsController {

  VoidCallback onDataModificationPressed(BuildContext context, int id, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => DataModification(id: id, role: role),),
      );
    };
  }
}