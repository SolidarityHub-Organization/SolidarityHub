import 'package:flutter_test/flutter_test.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
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
      final result = strategy.assignTasks(tasks as dynamic, volunteers as dynamic, 1);

      final totalAssignments = result.fold<int>(0, (sum, t) => sum + t.assignedVolunteers.length);
      expect(totalAssignments, 3);
    });
  });
}
