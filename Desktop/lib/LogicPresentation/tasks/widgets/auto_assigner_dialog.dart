import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicBusiness/handlers/auto_assigner.dart';
import 'package:solidarityhub/LogicBusiness/services/volunteer_service.dart';
import 'package:solidarityhub/models/task.dart';

enum AssignmentStrategyType { balanced, random }

Future<void> showAutoAssignerDialog(
  BuildContext context,
  List<TaskWithDetails> tasks,
) async {
  AssignmentStrategyType selectedStrategy = AssignmentStrategyType.balanced;
  int volunteersPerTask = 1;

  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController(text: '1');
  final ValueNotifier<int> affectedTasksNotifier = ValueNotifier(0);

  void updateAffectedTasks() {
    final value = int.tryParse(numberController.text);
    if (value == null || value <= 0) {
      affectedTasksNotifier.value = 0;
      return;
    }

    final count =
        tasks.where((task) => (task.assignedVolunteers.length) < value).length;
    affectedTasksNotifier.value = count;
  }

  numberController.addListener(updateAffectedTasks);
  updateAffectedTasks();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Auto-Assign Tasks'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AssignmentStrategyType>(
                value: selectedStrategy,
                decoration: const InputDecoration(labelText: 'Strategy'),
                items:
                    AssignmentStrategyType.values.map((strategy) {
                      return DropdownMenuItem(
                        value: strategy,
                        child: Text(strategy.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) selectedStrategy = value;
                },
              ),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Volunteers per Task',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num <= 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: affectedTasksNotifier,
                builder: (context, value, child) {
                  return Text(
                    'Tasks needing assignment: $value',
                    style: TextStyle(color: Colors.grey[700]),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                volunteersPerTask = int.parse(numberController.text);
                AssignmentStrategy strategy =
                    selectedStrategy == AssignmentStrategyType.balanced
                        ? BalancedAssignmentStrategy()
                        : RandomAssignmentStrategy();
                AutoAssigner(strategy).assignTasks(
                  tasks,
                  await VolunteerService.fetchVolunteers(),
                  volunteersPerTask,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Assign'),
          ),
        ],
      );
    },
  );

  numberController.dispose();
  affectedTasksNotifier.dispose();
}
