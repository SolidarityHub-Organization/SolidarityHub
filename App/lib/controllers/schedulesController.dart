import 'package:app/interface/volunteerPreferences.dart';
import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../interface/volunteerPreferences.dart';

class SchedulesController {
  String? selectedTime;

  void updateSelectedTime(String? time) {
    selectedTime = time;
  }

  void goToNextScreen(BuildContext context, UserRegistrationData userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolunteerPreferences(userData: userData), //Poner la pantalla siguiente
      ),
    );
  }
}