import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/task_table_controller.dart';

/// Widget que muestra el panel de filtros para la tabla de tareas
class TaskFilterPanel extends StatelessWidget {
  final TaskTableController controller;
  final VoidCallback onFilterChanged;

  const TaskFilterPanel({super.key, required this.controller, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtros y Ordenamiento'),
      backgroundColor: Colors.grey[50],
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la tarea',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        controller.nameFilter = value;
                        controller.applyFilters();
                        onFilterChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        controller.addressFilter = value;
                        controller.applyFilters();
                        onFilterChanged();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
                      value: controller.priorityFilter,
                      items:
                          ['Todas', 'Alta', 'Media', 'Baja'].map<DropdownMenuItem<String>>((String value) {
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
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () {
                      controller.sortAscending = !controller.sortAscending;
                      controller.applyFilters();
                      onFilterChanged();
                    },
                    tooltip: controller.sortAscending ? 'Cambiar a orden descendente' : 'Cambiar a orden ascendente',
                  ),
                  const Text('Ordenamiento:'),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Por ${controller.columns.firstWhere((c) => c.id == controller.sortField).label}'),
                    backgroundColor: Colors.grey[200],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.nameFilter = '';
                      controller.addressFilter = '';
                      controller.statusFilter = 'Todos';
                      controller.priorityFilter = 'Todas';
                      controller.sortField = 'name';
                      controller.sortAscending = true;
                      controller.applyFilters();
                      onFilterChanged();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar filtros'),
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
