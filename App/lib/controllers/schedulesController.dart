import 'package:app/interface/volunteerPreferences.dart';
import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';
import '../interface/volunteerPreferences.dart';

class SchedulesController {
  Set<String> selectedTimes = {};

  void updateSelectedTimes(String time, bool isSelected) {
    if (isSelected) {
      selectedTimes.add(time);
    } else {
      selectedTimes.remove(time);
    }
  }

  void goToNextScreen(BuildContext context, UserRegistrationData userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolunteerPreferences(userData: userData),
      ),
    );
  }
}
