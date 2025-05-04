import 'dart:math';

import 'package:solidarityhub/LogicBusiness/services/task_service.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPersistence/models/volunteer.dart';

abstract class AssignmentStrategy {
  void assignTasks(
    List<TaskWithDetails> tasks,
    List<Volunteer> volunteers,
    int volunteersPerTask,
  );
}

class RandomAssignmentStrategy implements AssignmentStrategy {
  @override
  void assignTasks(
    List<TaskWithDetails> tasks,
    List<Volunteer> volunteers,
    int volunteersPerTask,
  ) {
    final random = Random();

    for (var task in tasks) {
      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();

      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final availableVolunteers =
          volunteers.where((v) => !assignedIds.contains(v.id)).toList();

      availableVolunteers.shuffle(random);
      final toAssign = availableVolunteers.take(needed);

      task.assignedVolunteers.addAll(toAssign);
      TaskService.updateTask(task);
    }
  }
}

class AutoAssigner {
  AssignmentStrategy _strategy;

  AutoAssigner(this._strategy);

  void setStrategy(AssignmentStrategy strategy) {
    _strategy = strategy;
  }

  void assignTasks(
    List<TaskWithDetails> tasks,
    List<Volunteer> volunteers,
    int volunteersPerTask,
  ) {
    _strategy.assignTasks(tasks, volunteers, volunteersPerTask);
  }
}
