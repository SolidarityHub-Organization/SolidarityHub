import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicPersistence/models/location.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPersistence/models/volunteer.dart';

Future<void> showCreateTaskModal(
  BuildContext context,
  VoidCallback onTaskCreated,
  TaskWithDetails? taskToEdit,
) {
  return showDialog(
    context: context,
    builder:
        (context) => CreateTaskModal(
          onTaskCreated: onTaskCreated,
          taskToEdit: taskToEdit,
        ),
  );
}

class CreateTaskModal extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final TaskWithDetails? taskToEdit;

  const CreateTaskModal({
    super.key,
    required this.onTaskCreated,
    this.taskToEdit,
  });

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

Future<String> createTask({
  required String name,
  required String description,
  required List<int> selectedVolunteers,
  required int selectedLocation,
  int? taskId,
}) async {
  final url =
      taskId == null
          ? Uri.parse("http://localhost:5170/api/v1/tasks")
          : Uri.parse("http://localhost:5170/api/v1/tasks/$taskId");

  try {
    final Map<String, dynamic> taskData = {
      "name": name,
      "description": description,
      "admin_id": null,
      "location_id": selectedLocation,
      "volunteer_ids": selectedVolunteers,
    };

    if (taskId != null) {
      taskData['id'] = taskId;
    }

    final response =
        http.Request(taskId == null ? 'POST' : 'PUT', url)
          ..headers.addAll({'Content-Type': 'application/json'})
          ..body = json.encode(taskData);

    final streamedResponse = await response.send();
    final responseBody = await http.Response.fromStream(streamedResponse);

    if (responseBody.statusCode >= 200 && responseBody.statusCode <= 299) {
      return "Task has been added";
    } else {
      return "Error: ${responseBody.statusCode} - ${responseBody.body}";
    }
  } catch (error) {
    return "Error: $error";
  }
}

Future<List<T>> fetchData<T>(
  String endpoint,
  T Function(Map<String, dynamic>) fromJson,
) async {
  final url = Uri.parse("http://localhost:5170/api/v1/$endpoint");

  try {
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Error fetching $endpoint: ${response.statusCode}");
    }
  } catch (error) {
    throw Exception("Error: $error");
  }
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Volunteer> volunteers = [];
  List<Location> locations = [];
  List<int> selectedVolunteers = [];
  int selectedLocation = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.taskToEdit != null) {
      nameController.text = widget.taskToEdit!.name;
      descriptionController.text = widget.taskToEdit!.description;
      selectedLocation = widget.taskToEdit!.locationId;
      selectedVolunteers =
          widget.taskToEdit!.assignedVolunteers
              .map((volunteer) => volunteer.id)
              .toList();
    }
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        fetchData("volunteers", Volunteer.fromJson),
        fetchData("locations", Location.fromJson),
      ]);
      setState(() {
        volunteers = results[0] as List<Volunteer>;
        locations = results[1] as List<Location>;
        if (locations.isNotEmpty && widget.taskToEdit == null) {
          selectedLocation = locations[0].id;
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleCreateTask() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || selectedLocation == 0) {
      _showSnackBar('Por favor, complete todos los campos.');
      return;
    }

    final result = await createTask(
      name: name,
      description: description,
      selectedVolunteers: selectedVolunteers,
      selectedLocation: selectedLocation,
      taskId: widget.taskToEdit?.id,
    );

    if (result == "Task has been added") {
      widget.onTaskCreated();
    }

    if (mounted) {
      Navigator.pop(context);
    }
    _showSnackBar(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _contentBox(context),
    );
  }

  Widget _contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(widget.taskToEdit != null),
          const Divider(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildForm(),
          ),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: nameController, label: 'Nombre'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const Spacer(),
              _buildCreateButton(widget.taskToEdit != null),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'Ubicación',
                items: locations,
                selectedValue: selectedLocation,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLocation = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildVolunteerList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildCreateButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _handleCreateTask,
        child: Text(isEditing ? 'Editar Tarea' : 'Crear Tarea'),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Location> items,
    required int selectedValue,
    required ValueChanged<int?> onChanged,
  }) {
    print(selectedValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child:
              items.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Sin ubicaciones disponibles"),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedValue.toString(),
                      items:
                          items.map((item) {
                            final id = item.id.toString();
                            final name = "${item.latitude}, ${item.longitude}";
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        onChanged(value != null ? int.tryParse(value) : null);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildVolunteerList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voluntarios disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: volunteers.length,
              itemBuilder: (context, index) {
                final volunteer = volunteers[index];
                final isSelected = selectedVolunteers.contains(volunteer.id);
                return ListTile(
                  title: Text('${volunteer.name} ${volunteer.surname}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedVolunteers.add(volunteer.id);
                        } else {
                          selectedVolunteers.remove(volunteer.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
