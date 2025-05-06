import 'dart:math';

import 'package:solidarityhub/models/location.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/task.dart';

enum AssignmentStrategyType { proximity, balanced, random }

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

class ProximityAssignmentStrategy implements AssignmentStrategy {
  double _calculateDistance(Location a, Location b) {
    const earthRadius = 6371; // in kilometers
    final dLat = _degreesToRadians(b.latitude - a.latitude);
    final dLon = _degreesToRadians(b.longitude - a.longitude);

    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);

    final aCalc = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    for (var task in tasks) {
      if (task.location == null) continue;

      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();
      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final availableVolunteers = volunteers.where((v) => v.location != null && !assignedIds.contains(v.id)).toList();

      availableVolunteers.sort((a, b) {
        final distA = _calculateDistance(task.location!, a.location!);
        final distB = _calculateDistance(task.location!, b.location!);
        return distA.compareTo(distB);
      });

      final toAssign = availableVolunteers.take(needed);

      task.assignedVolunteers.addAll(toAssign);
      TaskService.updateTask(task);
    }
  }
}

class AutoAssigner {
  late AssignmentStrategy _strategy;

  AutoAssigner(AssignmentStrategyType strategyType) {
    setStrategy(strategyType);
  }

  void setStrategy(AssignmentStrategyType strategy) {
    switch (strategy) {
      case AssignmentStrategyType.balanced:
        _strategy = BalancedAssignmentStrategy();
        break;
      case AssignmentStrategyType.random:
        _strategy = RandomAssignmentStrategy();
        break;
      case AssignmentStrategyType.proximity:
        _strategy = ProximityAssignmentStrategy();
        break;
    }
  }

  void assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    _strategy.assignTasks(tasks, volunteers, volunteersPerTask);
  }
}
