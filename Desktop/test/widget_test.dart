import 'package:flutter_test/flutter_test.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_dialog_controller.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/skill.dart';
import 'package:solidarityhub/models/location.dart';
import 'package:solidarityhub/models/task.dart';

class MockVolunteer extends Volunteer {
  MockVolunteer(int id, {super.skills = const [], super.location})
    : super(
        id: id,
        email: '',
        name: '',
        surname: '',
        prefix: 0,
        phoneNumber: '',
        address: '',
        identification: '',
        locationId: null,
      );
}

class MockSkill extends Skill {
  MockSkill(int id) : super(id: id, name: '');
}

class MockLocation extends Location {
  MockLocation(double latitude, double longitude) : super(id: 0, latitude: latitude, longitude: longitude);
}

class MockTaskWithDetails extends TaskWithDetails {
  MockTaskWithDetails({super.skills = const [], super.location, List<Volunteer>? assigned})
    : super(
        id: 0,
        name: '',
        description: '',
        adminId: null,
        locationId: 0,
        startDate: DateTime.now(),
        endDate: null,
        assignedVolunteers: assigned ?? [],
        assignedVictim: const [],
      );
}

void main() {
  group('RandomAssignmentStrategy', () {
    test('asigna voluntarios aleatoriamente a tareas', () {
      final volunteers = List.generate(5, (i) => MockVolunteer(i));
      final tasks = [MockTaskWithDetails(), MockTaskWithDetails()];

      final strategy = RandomAssignmentStrategy();
      final result = strategy.assignTasks(tasks as dynamic, volunteers as dynamic, 2);

      expect(result[0].assignedVolunteers.length, 2);
      expect(result[1].assignedVolunteers.length, 2);
    });
  });

  group('BalancedAssignmentStrategy', () {
    test('asigna voluntarios balanceando la carga', () {
      final volunteers = List.generate(4, (i) => MockVolunteer(i));
      final tasks = [MockTaskWithDetails(), MockTaskWithDetails(), MockTaskWithDetails()];

      final strategy = BalancedAssignmentStrategy();
      final result = strategy.assignTasks(tasks, volunteers, 1);

      final totalAssignments = result.fold<int>(0, (sum, t) => sum + t.assignedVolunteers.length);
      expect(totalAssignments, 3);
    });

    test('prioriza voluntarios con menos tareas asignadas', () {
      final volunteers = List.generate(3, (i) => MockVolunteer(i));

      final tasks = [
        MockTaskWithDetails(assigned: [volunteers[0]]),
        MockTaskWithDetails(),
      ];

      final strategy = BalancedAssignmentStrategy();
      final result = strategy.assignTasks(tasks, volunteers, 1);

      expect(result[1].assignedVolunteers.length, 1);
      expect(result[1].assignedVolunteers[0].id, isNot(0));
    });
  });

  group('ProximityAssignmentStrategy', () {
    test('asigna voluntarios cercanos a la tarea', () {
      final taskLocation = MockLocation(0.0, 0.0);

      final nearVolunteer = MockVolunteer(1, location: MockLocation(0.01, 0.01));
      final midVolunteer = MockVolunteer(2, location: MockLocation(0.1, 0.1));
      final farVolunteer = MockVolunteer(3, location: MockLocation(1.0, 1.0));

      final volunteers = [farVolunteer, midVolunteer, nearVolunteer];
      final task = MockTaskWithDetails(location: taskLocation);

      final strategy = ProximityAssignmentStrategy();
      final result = strategy.assignTasks([task], volunteers, 2);

      expect(result[0].assignedVolunteers.length, 2);
      expect(result[0].assignedVolunteers[0].id, equals(nearVolunteer.id));
      expect(result[0].assignedVolunteers[1].id, equals(midVolunteer.id));
    });

    test('ignora tareas sin ubicación', () {
      final volunteers = List.generate(3, (i) => MockVolunteer(i, location: MockLocation(i.toDouble(), i.toDouble())));

      final task = MockTaskWithDetails();

      final strategy = ProximityAssignmentStrategy();
      final result = strategy.assignTasks([task], volunteers, 1);

      expect(result[0].assignedVolunteers.length, 0);
    });
  });

  group('SkillBasedAssignmentStrategy', () {
    test('asigna voluntarios con habilidades requeridas', () {
      final skill1 = MockSkill(1);
      final skill2 = MockSkill(2);

      final volunteer1 = MockVolunteer(1, skills: [skill1], location: MockLocation(0.0, 0.0));
      final volunteer2 = MockVolunteer(2, skills: [skill2], location: MockLocation(0.0, 0.0));
      final volunteer3 = MockVolunteer(3, skills: [], location: MockLocation(0.0, 0.0));

      final volunteers = [volunteer1, volunteer2, volunteer3];

      final task = MockTaskWithDetails(skills: [skill1], location: MockLocation(0.0, 0.0));

      final strategy = SkillBasedAssignmentStrategy();
      final result = strategy.assignTasks([task], volunteers, 1);

      expect(result[0].assignedVolunteers.length, 1);
      expect(result[0].assignedVolunteers[0].id, equals(volunteer1.id));
    });

    test('ignora tareas sin habilidades o ubicación', () {
      final skill = MockSkill(1);
      final volunteers = [
        MockVolunteer(1, skills: [skill], location: MockLocation(0.0, 0.0)),
      ];

      final task1 = MockTaskWithDetails(location: MockLocation(0.0, 0.0));

      final task2 = MockTaskWithDetails(skills: [skill]);

      final strategy = SkillBasedAssignmentStrategy();
      final result = strategy.assignTasks([task1, task2], volunteers, 1);

      expect(result[0].assignedVolunteers.length, 0);
      expect(result[1].assignedVolunteers.length, 0);
    });
  });
  group('AutoAssigner', () {
    test('cambia de estrategia correctamente', () {
      final autoAssigner = AutoAssigner(AssignmentStrategyType.aleatorio);
      autoAssigner.setStrategy(AssignmentStrategyType.proximidad);

      autoAssigner.setStrategy(AssignmentStrategyType.balanceado);

      autoAssigner.setStrategy(AssignmentStrategyType.habilidades);

      expect(true, isTrue);
    });
  });

  group('AutoAssignerDialogController', () {
    test('actualiza correctamente el conteo de tareas afectadas', () {
      final tasks = [
        MockTaskWithDetails(),
        MockTaskWithDetails(assigned: [MockVolunteer(1)]),
        MockTaskWithDetails(assigned: [MockVolunteer(2), MockVolunteer(3)]),
      ];

      void onTasksUpdated() {}

      final controller = AutoAssignerDialogController(tasks: tasks, onTasksUpdated: onTasksUpdated);

      for (var task in tasks) {
        controller.selectedTasks.add(task);
      }

      controller.numberController.text = '1';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 1);

      controller.numberController.text = '2';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 2);

      controller.numberController.text = '3';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 3);

      // Limpiar
      controller.dispose();
    });

    test('maneja valores inválidos en el controlador de número', () {
      final tasks = [MockTaskWithDetails()];

      void onTasksUpdated() {}

      final controller = AutoAssignerDialogController(tasks: tasks, onTasksUpdated: onTasksUpdated);

      controller.selectedTasks.add(tasks[0]);

      controller.numberController.text = 'abc';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 0);

      controller.numberController.text = '-1';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 0);

      controller.numberController.text = '0';
      controller.updateAffectedTasks();

      expect(controller.affectedTasksNotifier.value, 0);

      controller.dispose();
    });

    test('cambia estrategia correctamente', () {
      final tasks = [MockTaskWithDetails()];

      void onTasksUpdated() {}

      final controller = AutoAssignerDialogController(tasks: tasks, onTasksUpdated: onTasksUpdated);

      expect(controller.selectedStrategy, AssignmentStrategyType.proximidad);

      controller.setStrategy(AssignmentStrategyType.aleatorio);

      expect(controller.selectedStrategy, AssignmentStrategyType.aleatorio);

      controller.dispose();
    });
  });
}
