import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/controllers/tasks/create_task_controller.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/widgets/common/snack_bar.dart';

Future<void> showCreateTaskModal(BuildContext context, VoidCallback onTaskCreated, TaskWithDetails? taskToEdit) {
  return showDialog(
    context: context,
    builder: (context) => CreateTaskModal(onTaskCreated: onTaskCreated, taskToEdit: taskToEdit),
  );
}

class CreateTaskModal extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final TaskWithDetails? taskToEdit;

  const CreateTaskModal({super.key, required this.onTaskCreated, this.taskToEdit});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  late final CreateTaskController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateTaskController(onTaskCreated: widget.onTaskCreated, taskToEdit: widget.taskToEdit);
    _loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await controller.loadData();
      setState(() {});
    } catch (error) {
      if (mounted) {
        AppSnackBar.show(context: context, message: error.toString(), type: SnackBarType.error);
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      controller.onMapTap(tapPosition, location);
    });
  }

  Future<void> _handleCreateTask() async {
    try {
      final result = await controller.handleCreateTask();

      if (result == 'success') {
        if (mounted) {
          Navigator.pop(context);
          AppSnackBar.show(
            context: context,
            message: widget.taskToEdit != null ? 'Tarea actualizada correctamente' : 'Tarea creada correctamente',
            type: SnackBarType.success,
          );
        }
      } else {
        if (mounted) {
          AppSnackBar.show(context: context, message: result, type: SnackBarType.error);
        }
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.show(context: context, message: 'Error: $error', type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _contentBox(context),
      ),
    );
  }

  Widget _contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          _buildHeader(widget.taskToEdit != null),
          const Divider(),
          Expanded(child: controller.isLoading ? const Center(child: CircularProgressIndicator()) : _buildForm()),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Editar Tarea' : 'Crear Tarea',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [Expanded(child: _buildTextField(controller: controller.nameController, label: 'Nombre'))],
                ),
                const SizedBox(height: 8),
                _buildTextField(controller: controller.descriptionController, label: 'Descripción', maxLines: 2),
                const SizedBox(height: 4),
                _buildDateFields(),
                const SizedBox(height: 4),
                SizedBox(height: 300, child: _buildLocationFields()),
                const SizedBox(height: 6),
                _buildCreateButton(widget.taskToEdit != null),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildVolunteerSection()),
              const SizedBox(height: 12),
              Expanded(child: _buildVictimSection()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fechas y horas de la tarea', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            // Fecha de inicio
            Expanded(
              child: _buildDateField(
                label: 'Fecha de inicio',
                date: controller.startDate,
                onDateSelected: (date) {
                  setState(() {
                    // Preservar la hora actual al cambiar la fecha
                    final currentTime =
                        controller.startDate != null
                            ? TimeOfDay(hour: controller.startDate!.hour, minute: controller.startDate!.minute)
                            : TimeOfDay.now();
                    controller.setStartDate(
                      DateTime(date.year, date.month, date.day, currentTime.hour, currentTime.minute),
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            // Hora de inicio
            Expanded(
              child: _buildTimeField(
                label: 'Hora de inicio',
                dateTime: controller.startDate,
                onTimeSelected: (time) {
                  setState(() {
                    // Si ya hay una fecha, actualizar solo la hora
                    final currentDate = controller.startDate ?? DateTime.now();
                    controller.setStartDate(
                      DateTime(currentDate.year, currentDate.month, currentDate.day, time.hour, time.minute),
                    );
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Fecha de fin
            Expanded(
              child: _buildDateField(
                label: 'Fecha de fin (opcional)',
                date: controller.endDate,
                onDateSelected: (date) {
                  setState(() {
                    // Preservar la hora actual al cambiar la fecha
                    final currentTime =
                        controller.endDate != null
                            ? TimeOfDay(hour: controller.endDate!.hour, minute: controller.endDate!.minute)
                            : TimeOfDay.now();
                    controller.setEndDate(
                      DateTime(date.year, date.month, date.day, currentTime.hour, currentTime.minute),
                    );
                  });
                },
                isOptional: true,
              ),
            ),
            const SizedBox(width: 8),
            // Hora de fin
            Expanded(
              child: _buildTimeField(
                label: 'Hora de fin (opcional)',
                dateTime: controller.endDate,
                onTimeSelected: (time) {
                  setState(() {
                    // Si ya hay una fecha, actualizar solo la hora
                    final currentDate = controller.endDate ?? DateTime.now();
                    controller.setEndDate(
                      DateTime(currentDate.year, currentDate.month, currentDate.day, time.hour, time.minute),
                    );
                  });
                },
                isOptional: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required DateTime? dateTime,
    required Function(TimeOfDay) onTimeSelected,
    bool isOptional = false,
  }) {
    // Extraer TimeOfDay del DateTime si está disponible
    TimeOfDay? time = dateTime != null ? TimeOfDay(hour: dateTime.hour, minute: dateTime.minute) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 1),
        InkWell(
          onTap: () async {
            final TimeOfDay initialTime = time ?? TimeOfDay.now();

            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: initialTime,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.red, onPrimary: Colors.white)),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              onTimeSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(6.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null
                      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                      : isOptional
                      ? 'No especificada'
                      : 'Selecciona una hora',
                  style: TextStyle(color: time != null ? Colors.black : Colors.grey, fontSize: 10),
                ),
                const Icon(Icons.access_time, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 1),
        InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime minDate = date != null && date.isBefore(now) ? date : now;

            final DateTime initialDate = date ?? now;

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: minDate,
              lastDate: DateTime(now.year + 5),
            );

            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(6.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : isOptional
                      ? 'No especificada'
                      : 'Selecciona una fecha',
                  style: TextStyle(color: date != null ? Colors.black : Colors.grey, fontSize: 10),
                ),
                const Icon(Icons.calendar_today, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ubicación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.searchAddressController,
                label: 'Buscar dirección',
                prefixIcon: const Icon(Icons.search, size: 16),
                onClear: () {
                  setState(() {
                    controller.searchAddressController.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => controller.searchAddress(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.grey)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(initialCenter: controller.selectedLocation, initialZoom: 13, onTap: _onMapTap),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  MarkerLayer(markers: controller.markers),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voluntarios disponibles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.searchVolunteersController,
                label: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search, size: 16),
                onClear: () {
                  setState(() {
                    controller.searchVolunteersController.clear();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.searchSkillsController,
          label: 'Filtrar por habilidades',
          prefixIcon: const Icon(Icons.filter_list, size: 16),
          onClear: () {
            setState(() {
              controller.searchSkillsController.clear();
            });
          },
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.grey)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.filteredVolunteers().length,
              itemBuilder: (context, index) {
                final volunteer = controller.filteredVolunteers()[index];
                final isSelected = controller.selectedVolunteers.contains(volunteer.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                  elevation: 0,
                  color: isSelected ? Colors.red.withAlpha(26) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: isSelected ? Colors.red : Colors.transparent, width: 1),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                    title: Text(
                      '${volunteer.name} ${volunteer.surname}',
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                    ),
                    subtitle: Wrap(
                      spacing: 3.0,
                      runSpacing: 3.0,
                      children:
                          volunteer.skills.map<Widget>((skill) {
                            return Chip(
                              label: Text(skill.name, style: const TextStyle(fontSize: 9)),
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(side: BorderSide(color: Colors.grey, width: 0.5)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0),
                            );
                          }).toList(),
                    ),
                    trailing: Checkbox(
                      activeColor: Colors.red,
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          controller.toggleVolunteerSelection(volunteer.id, value ?? false);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVictimSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Afectados disponibles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.searchVictimController,
                label: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search, size: 16),
                onClear: () {
                  setState(() {
                    controller.searchVictimController.clear();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.searchNeedsController,
          label: 'Filtrar por necesidades',
          prefixIcon: const Icon(Icons.filter_list, size: 16),
          onClear: () {
            setState(() {
              controller.searchNeedsController.clear();
            });
          },
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.grey)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.filteredVictim().length,
              itemBuilder: (context, index) {
                final person = controller.filteredVictim()[index];
                final isSelected = controller.selectedVictim.contains(person.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                  elevation: 0,
                  color: isSelected ? Colors.red.withAlpha(26) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: isSelected ? Colors.red : Colors.transparent, width: 1),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                    title: Text(
                      '${person.name} ${person.surname}',
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                    ),
                    subtitle: FutureBuilder<Map<String, dynamic>>(
                      future: controller.fetchVictimNeeds(person.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            'Cargando necesidades...',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                          );
                        } else {
                          return Text(
                            controller.getFormattedNeedsForVictim(person.id),
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                      },
                    ),
                    trailing: Checkbox(
                      activeColor: Colors.red,
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          controller.toggleVictimSelection(person.id, value ?? false);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    bool showClear = true,
    VoidCallback? onClear,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        prefixIcon: prefixIcon != null ? SizedBox(width: 16, height: 16, child: Center(child: prefixIcon)) : null,
        suffixIcon:
            showClear && controller.text.isNotEmpty
                ? IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear();
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    );
  }

  Widget _buildCreateButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: _handleCreateTask,
        icon: Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white, size: 18),
        label: Text(isEditing ? 'Actualizar Tarea' : 'Crear Tarea', style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
