import 'package:app/interface/volunteerPreferences.dart';
import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../models/user_registration_data.dart';

class SchedulesController {
  Set<String> selectedTimes = {};

  void updateSelectedTimes(String time, bool isSelected) {
    if (isSelected) {
      selectedTimes.add(time);
    } else {
      selectedTimes.remove(time);
    }
  }

  void goToNextScreen(BuildContext context, RegisterFlowManager manager) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolunteerPreferences(manager: manager),
      ),
    );
  }
}
