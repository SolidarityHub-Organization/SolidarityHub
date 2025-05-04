import 'dart:math';

import 'package:solidarityhub/services/task_service.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/task.dart';

abstract class AssignmentStrategy {
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask);
}

class RandomAssignmentStrategy implements AssignmentStrategy {
  @override
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    final random = Random();

    for (var task in tasks) {
      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();

      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final availableVolunteers = volunteers.where((v) => !assignedIds.contains(v.id)).toList();

      availableVolunteers.shuffle(random);
      final toAssign = availableVolunteers.take(needed);

      task.assignedVolunteers.addAll(toAssign);
      TaskService.updateTask(task);
    }
  }
}

class BalancedAssignmentStrategy implements AssignmentStrategy {
  @override
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    final taskCountPerVolunteer = <int, int>{};

    for (var task in tasks) {
      for (var v in task.assignedVolunteers) {
        taskCountPerVolunteer[v.id] = (taskCountPerVolunteer[v.id] ?? 0) + 1;
      }
    }

    for (var task in tasks) {
      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();
      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final available = volunteers.where((v) => !assignedIds.contains(v.id)).toList();

      available.sort((a, b) {
        final countA = taskCountPerVolunteer[a.id] ?? 0;
        final countB = taskCountPerVolunteer[b.id] ?? 0;
        return countA.compareTo(countB);
      });

      final toAssign = available.take(needed);
      for (var v in toAssign) {
        task.assignedVolunteers.add(v);
        taskCountPerVolunteer[v.id] = (taskCountPerVolunteer[v.id] ?? 0) + 1;
      }

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

  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    _strategy.assignTasks(tasks, volunteers, volunteersPerTask);
  }
}
