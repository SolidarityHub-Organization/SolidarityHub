import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';

class TaskFilterPanel extends StatelessWidget {
  final TaskTableController controller;
  final VoidCallback onFilterChanged;

  const TaskFilterPanel({super.key, required this.controller, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtros'),
      backgroundColor: Colors.grey[50],
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarea',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
                onChanged: (value) {
                  controller.nameFilter = value;
                  controller.applyFilters();
                  onFilterChanged();
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      ),
                      value: controller.statusFilter,
                      items:
                          ['Todos', 'Asignado', 'Pendiente', 'Completado', 'Cancelado'].map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.statusFilter = newValue;
                          controller.applyFilters();
                          onFilterChanged();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      ),
                      value: controller.priorityFilter,
                      items:
                          ['Todas', 'Crítico', 'Alto', 'Medio', 'Bajo'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.priorityFilter = newValue;
                          controller.applyFilters();
                          onFilterChanged();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      controller.nameFilter = '';
                      controller.statusFilter = 'Todos';
                      controller.priorityFilter = 'Todas';
                      controller.sortField = 'name';
                      controller.sortAscending = true;
                      controller.applyFilters();
                      onFilterChanged();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      minimumSize: const Size(100, 48),
                    ),
                    child: const Text('Limpiar Filtros'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
