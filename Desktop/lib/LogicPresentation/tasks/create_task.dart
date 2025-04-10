import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicBusiness/handlers/task_handler.dart';
import 'package:solidarityhub/LogicPersistence/models/location.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPersistence/models/volunteer.dart';
import 'package:solidarityhub/LogicPresentation/dashboard/common_widgets.dart';

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
  required double latitude,
  required double longitude,
  int? taskId,
}) async {
  // First create the location
  final locationUrl = Uri.parse("http://localhost:5170/api/v1/locations");
  final locationData = {"latitude": latitude, "longitude": longitude};

  final locationResponse = await http.post(
    locationUrl,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(locationData),
  );

  if (locationResponse.statusCode < 200 || locationResponse.statusCode > 299) {
    return "Error creating location: ${locationResponse.statusCode} - ${locationResponse.body}";
  }

  // Get the new location ID
  final locationResult = json.decode(locationResponse.body);
  final int locationId = locationResult['id'];

  final Map<String, dynamic> taskData = {
    "name": name,
    "description": description,
    "admin_id": null,
    "location_id": locationId,
    "volunteer_ids": selectedVolunteers,
  };

  final validationHandler = ValidationHandler();
  final persistenceHandler = PersistenceHandler();

  validationHandler.setNext(persistenceHandler);

  return await validationHandler.handle(taskData);
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
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  List<Volunteer> volunteers = [];
  List<int> selectedVolunteers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.taskToEdit != null) {
      nameController.text = widget.taskToEdit!.name;
      descriptionController.text = widget.taskToEdit!.description;
      _loadTaskLocation();
      selectedVolunteers =
          widget.taskToEdit!.assignedVolunteers
              .map((volunteer) => volunteer.id)
              .toList();
    } else {
      latitudeController.text = "0.0";
      longitudeController.text = "0.0";
    }
  }

  Future<void> _loadTaskLocation() async {
    if (widget.taskToEdit != null) {
      try {
        final url = Uri.parse(
          "http://localhost:5170/api/v1/locations/${widget.taskToEdit!.locationId}",
        );
        final response = await http.get(url);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          final location = json.decode(response.body);
          setState(() {
            latitudeController.text = location['latitude'].toString();
            longitudeController.text = location['longitude'].toString();
          });
        }
      } catch (error) {
        AppSnackBar.show(
          context: context,
          message: "Error loading location: $error",
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        fetchData("volunteers", Volunteer.fromJson),
      ]);
      setState(() {
        volunteers = results[0];
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AppSnackBar.show(
        context: context,
        message: error.toString(),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _handleCreateTask() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    double? latitude = double.tryParse(latitudeController.text);
    double? longitude = double.tryParse(longitudeController.text);

    if (name.isEmpty ||
        description.isEmpty ||
        latitude == null ||
        longitude == null) {
      AppSnackBar.show(
        context: context,
        message: "Por favor, complete todos los campos.",
        type: SnackBarType.error,
      );
      return;
    }

    final result = await createTask(
      name: name,
      description: description,
      selectedVolunteers: selectedVolunteers,
      latitude: latitude,
      longitude: longitude,
      taskId: widget.taskToEdit?.id,
    );

    if (result.startsWith("OK")) {
      widget.onTaskCreated();
    }

    if (mounted) {
      Navigator.pop(context);
    }
    AppSnackBar.show(
      context: context,
      message: result,
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _contentBox(context),
      ),
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
              const SizedBox(height: 16),
              _buildLocationFields(),
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
            children: [_buildVolunteerList()],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: latitudeController,
                label: 'Latitud',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: longitudeController,
                label: 'Longitud',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
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
