import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_dialog_controller.dart';
import 'package:solidarityhub/controllers/tasks/auto_assigner_controller.dart';
import 'package:solidarityhub/models/task.dart';

class AutoAssignerDialog extends StatefulWidget {
  final VoidCallback onTasksUpdated;
  final List<TaskWithDetails> tasks;

  const AutoAssignerDialog({super.key, required this.tasks, required this.onTasksUpdated});

  @override
  State<AutoAssignerDialog> createState() => _AutoAssignerDialogState();
}

class _AutoAssignerDialogState extends State<AutoAssignerDialog> {
  late final AutoAssignerDialogController controller;

  @override
  void initState() {
    super.initState();
    controller = AutoAssignerDialogController(tasks: widget.tasks, onTasksUpdated: widget.onTasksUpdated);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: screenSize.width * 0.6,
        height: screenSize.height * 0.6,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), const Divider(height: 1), Expanded(child: _buildContent())],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Auto Asignar Tareas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8.0)),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStrategyField(),
                        const SizedBox(height: 16),
                        _buildVolunteersField(),
                        const SizedBox(height: 16),
                        _buildAffectedTasksInfo(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona las tareas a asignar:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Scrollbar(
                            thickness: 8,
                            radius: const Radius.circular(4),
                            child: ListView.builder(
                              itemCount: widget.tasks.length,
                              itemBuilder: (context, index) {
                                final task = widget.tasks[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 0.5)),
                                  ),
                                  child: CheckboxListTile(
                                    title: Text(task.name, style: const TextStyle(fontSize: 13)),
                                    subtitle: Text(
                                      'Voluntarios actuales: ${task.assignedVolunteers.length}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: controller.selectedTasks.contains(task),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          controller.selectedTasks.add(task);
                                        } else {
                                          controller.selectedTasks.remove(task);
                                        }
                                        controller.updateAffectedTasks();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
          child: _buildAssignButton(),
        ),
      ],
    );
  }

  Widget _buildStrategyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estrategia de Asignación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<AssignmentStrategyType>(
          value: controller.selectedStrategy,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
            filled: true,
            fillColor: Colors.white,
          ),
          items:
              AssignmentStrategyType.values.map((strategy) {
                return DropdownMenuItem(
                  value: strategy,
                  child: Text(strategy.name[0].toUpperCase() + strategy.name.substring(1)),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                controller.setStrategy(value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildVolunteersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voluntarios por Tarea', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.numberController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            final num = int.tryParse(value ?? '');
            if (num == null || num <= 0) {
              return 'Introduce un número válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAffectedTasksInfo() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.affectedTasksNotifier,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Se actualizarán los voluntarios de $value tareas.',
                  style: TextStyle(color: Colors.blue[900], fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: () async {
          final success = await controller.assignTasks(context);
          if (success && mounted) {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(Icons.auto_fix_high, color: Colors.white, size: 18),
        label: const Text('Asignar Tareas', style: TextStyle(fontSize: 14)),
      ),
    );
  }
}

Future<void> showAutoAssignerDialog(
  BuildContext context,
  List<TaskWithDetails> tasks,
  VoidCallback onTasksUpdated,
) async {
  await showDialog(
    context: context,
    builder: (context) => AutoAssignerDialog(tasks: tasks, onTasksUpdated: onTasksUpdated),
  );
}
