import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/controllers/tasks/create_task_controller.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/widgets/common/snack_bar.dart';

Future<void> showCreateTaskModal(BuildContext context, VoidCallback onTaskCreated, TaskWithDetails? taskToEdit) {
  return showDialog(
    context: context,
    barrierDismissible: false,
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
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: screenSize.width * 0.9,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(widget.taskToEdit != null),
            const Divider(height: 1),
            Expanded(child: controller.isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: _buildDesktopLayout())),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
          child: _buildCreateButton(widget.taskToEdit != null),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Scrollbar(
      thickness: 8,
      radius: const Radius.circular(4),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Expanded(child: _buildTextField(controller: controller.nameController, label: 'Nombre'))]),
            const SizedBox(height: 12),
            _buildTextField(controller: controller.descriptionController, label: 'Descripción', maxLines: 2),
            const SizedBox(height: 12),
            _buildDateFields(),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: _buildLocationFields()),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildVolunteerSection()),
                const SizedBox(width: 16),
                Expanded(child: _buildVictimSection()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Editar Tarea' : 'Crear Tarea',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fechas y horas de la tarea', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Fecha de inicio',
                date: controller.startDate,
                onDateSelected: (date) {
                  setState(() {
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
            Expanded(
              child: _buildTimeField(
                label: 'Hora de inicio',
                dateTime: controller.startDate,
                onTimeSelected: (time) {
                  setState(() {
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Fecha de fin (opcional)',
                date: controller.endDate,
                onDateSelected: (date) {
                  setState(() {
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
            Expanded(
              child: _buildTimeField(
                label: 'Hora de fin (opcional)',
                dateTime: controller.endDate,
                onTimeSelected: (time) {
                  setState(() {
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
    TimeOfDay? time = dateTime != null ? TimeOfDay(hour: dateTime.hour, minute: dateTime.minute) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  style: TextStyle(color: time != null ? Colors.black : Colors.grey, fontSize: 12),
                ),
                const Icon(Icons.access_time, size: 16),
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
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  style: TextStyle(color: date != null ? Colors.black : Colors.grey, fontSize: 12),
                ),
                const Icon(Icons.calendar_today, size: 16),
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
        const SizedBox(height: 8),
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Icon(Icons.search, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Voluntarios disponibles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.searchVolunteersController,
            label: 'Buscar por nombre',
            prefixIcon: const Icon(Icons.search, size: 16),
            onChanged: (value) => setState(() {}),
            onClear: () {
              setState(() {
                controller.searchVolunteersController.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.searchSkillsController,
            label: 'Filtrar por habilidades',
            prefixIcon: const Icon(Icons.filter_list, size: 16),
            onChanged: (value) => setState(() {}),
            onClear: () {
              setState(() {
                controller.searchSkillsController.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
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
        ],
      ),
    );
  }

  Widget _buildVictimSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Afectados disponibles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.searchVictimController,
            label: 'Buscar por nombre',
            prefixIcon: const Icon(Icons.search, size: 16),
            onChanged: (value) => setState(() {}),
            onClear: () {
              setState(() {
                controller.searchVictimController.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.searchNeedsController,
            label: 'Filtrar por necesidades',
            prefixIcon: const Icon(Icons.filter_list, size: 16),
            onChanged: (value) => setState(() {}),
            onClear: () {
              setState(() {
                controller.searchNeedsController.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
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
        ],
      ),
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
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        prefixIcon: prefixIcon != null ? SizedBox(width: 40, height: 40, child: Center(child: prefixIcon)) : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon:
            showClear && controller.text.isNotEmpty
                ? IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear();
                    if (onChanged != null) onChanged('');
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: _handleCreateTask,
        icon: Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white, size: 18),
        label: Text(isEditing ? 'Actualizar Tarea' : 'Crear Tarea', style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
