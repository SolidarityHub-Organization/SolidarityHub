import 'package:flutter/material.dart';
import '../interface/dataModification.dart';

class SettingsController {

  VoidCallback onDataModificationPressed(BuildContext context, String email, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => DataModification(email: email, role: role),),
      );
    };
  }
}