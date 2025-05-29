import 'dart:math';
import 'package:solidarityhub/models/location.dart';
import 'package:solidarityhub/models/skill.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/task.dart';

enum AssignmentStrategyType { proximidad, habilidades, balanceado, aleatorio }

abstract class AssignmentStrategy {
  List<TaskWithDetails> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask);
}

class RandomAssignmentStrategy implements AssignmentStrategy {
  @override
  List<TaskWithDetails> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    final random = Random();

    for (var task in tasks) {
      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();

      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final availableVolunteers = volunteers.where((v) => !assignedIds.contains(v.id)).toList();

      availableVolunteers.shuffle(random);
      final toAssign = availableVolunteers.take(needed);

      task.assignedVolunteers.addAll(toAssign);
    }

    return tasks;
  }
}

class BalancedAssignmentStrategy implements AssignmentStrategy {
  @override
  List<TaskWithDetails> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
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
    }

    return tasks;
  }
}

class ProximityAssignmentStrategy implements AssignmentStrategy {
  @override
  List<TaskWithDetails> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
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
    }

    return tasks;
  }
}

class SkillBasedAssignmentStrategy implements AssignmentStrategy {
  bool _hasRequiredSkills(Volunteer v, List<Skill> requiredSkills) {
    final requiredIds = requiredSkills.map((s) => s.id).toSet();
    return v.skills.any((skill) => requiredIds.contains(skill.id));
  }

  @override
  List<TaskWithDetails> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) {
    for (var task in tasks) {
      if (task.location == null || task.skills.isEmpty) continue;

      final assignedIds = task.assignedVolunteers.map((v) => v.id).toSet();
      final needed = volunteersPerTask - assignedIds.length;
      if (needed <= 0) continue;

      final matchingVolunteers =
          volunteers
              .where((v) => v.location != null && !assignedIds.contains(v.id) && _hasRequiredSkills(v, task.skills))
              .toList();

      matchingVolunteers.sort((a, b) {
        final distA = _calculateDistance(task.location!, a.location!);
        final distB = _calculateDistance(task.location!, b.location!);
        return distA.compareTo(distB);
      });

      final toAssign = matchingVolunteers.take(needed);

      task.assignedVolunteers.addAll(toAssign);
    }

    return tasks;
  }
}

class AutoAssigner {
  late AssignmentStrategy _strategy;
  List<TaskWithDetails>? _previousState;

  AutoAssigner(AssignmentStrategyType strategyType) {
    setStrategy(strategyType);
  }

  void setStrategy(AssignmentStrategyType strategy) {
    switch (strategy) {
      case AssignmentStrategyType.balanceado:
        _strategy = BalancedAssignmentStrategy();
        break;
      case AssignmentStrategyType.aleatorio:
        _strategy = RandomAssignmentStrategy();
        break;
      case AssignmentStrategyType.proximidad:
        _strategy = ProximityAssignmentStrategy();
        break;
      case AssignmentStrategyType.habilidades:
        _strategy = SkillBasedAssignmentStrategy();
        break;
    }
  }

  Future<void> assignTasks(List<TaskWithDetails> tasks, List<Volunteer> volunteers, int volunteersPerTask) async {
    _previousState =
        tasks
            .map(
              (task) => TaskWithDetails(
                id: task.id,
                name: task.name,
                description: task.description,
                adminId: task.adminId,
                locationId: task.locationId,
                startDate: task.startDate,
                endDate: task.endDate,
                assignedVolunteers: List.from(task.assignedVolunteers),
                assignedVictim: List.from(task.assignedVictim),
                location: task.location,
                skills: List.from(task.skills),
              ),
            )
            .toList();

    List<TaskWithDetails> tasksToUpdate = _strategy.assignTasks(tasks, volunteers, volunteersPerTask);
    List<Future> futures = [];

    for (var task in tasksToUpdate) {
      futures.add(TaskServices.updateTask(task));
    }

    await Future.wait(futures);
  }

  Future<void> undoAssignment() async {
    if (_previousState == null) return;

    List<Future> futures = [];
    for (var task in _previousState!) {
      futures.add(TaskServices.updateTask(task));
    }

    await Future.wait(futures);
    _previousState = null;
  }
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

double _calculateDistance(Location a, Location b) {
  const earthRadius = 6371;
  final dLat = _degreesToRadians(b.latitude - a.latitude);
  final dLon = _degreesToRadians(b.longitude - a.longitude);

  final lat1 = _degreesToRadians(a.latitude);
  final lat2 = _degreesToRadians(b.latitude);

  final aCalc = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  final c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));
  return earthRadius * c;
}
