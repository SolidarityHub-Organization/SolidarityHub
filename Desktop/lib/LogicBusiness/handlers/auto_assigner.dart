import 'dart:math';

import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPersistence/models/volunteer.dart';

abstract class AssignmentStrategy {
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers);
}

class RandomAssignmentStrategy implements AssignmentStrategy {
  @override
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers) {
    for (var task in tasks) {
      var volunteer = volunteers[Random().nextInt(volunteers.length)];
      task.assignedVolunteers.add(volunteer);
    }
  }
}

class AutoAssigner {
  AssignmentStrategy _strategy;

  AutoAssigner(this._strategy);

  void setStrategy(AssignmentStrategy strategy) {
    _strategy = strategy;
  }

  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers) {
    _strategy.assignTasks(tasks, volunteers);
  }
}
