import 'package:flutter/material.dart';
import '../interface/dataModification.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsController {

  VoidCallback onDataModificationPressed(BuildContext context, int id, String role) {
    return () {
      Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => DataModification(id: id, role: role),),
      );
    };
  }

  onDeleteAccountPressed(BuildContext context, int id, String role) async {
    if (role == 'volunteer') {
      final url = Uri.parse('http://localhost:5170/api/v1/volunteers/$id');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
        }),
      );
      return response;
    } else if (role == 'victim') {
      final url = Uri.parse('http://localhost:5170/api/v1/victims/$id');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
        }),
      );
      return response;
    }
  }
}