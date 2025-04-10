import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> showCreateTaskModal(
  BuildContext context,
  VoidCallback onTaskCreated,
) {
  return showDialog(
    context: context,
    builder: (context) => CreateTaskModal(onTaskCreated: onTaskCreated),
  );
}

class CreateTaskModal extends StatefulWidget {
  final VoidCallback onTaskCreated;

  const CreateTaskModal({super.key, required this.onTaskCreated});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

Future<String> createTask({
  required String name,
  required String description,
  required List<int> selectedVolunteers,
  required String selectedLocation,
}) async {
  final url = Uri.parse("http://localhost:5170/api/v1/tasks");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "description": description,
        "admin_id": null,
        "location_id": selectedLocation,
        "volunteer_ids": selectedVolunteers,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return "Task has been added";
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  } catch (error) {
    return "Error: $error";
  }
}

Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse("http://localhost:5170/api/v1/$endpoint");

  try {
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
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
  List<Map<String, dynamic>> volunteers = [];
  List<Map<String, dynamic>> locations = [];
  List<int> selectedVolunteers = [];
  String selectedLocation = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        fetchData("volunteers"),
        fetchData("locations"),
      ]);
      setState(() {
        volunteers = results[0];
        locations = results[1];
        if (locations.isNotEmpty) {
          selectedLocation = locations[0]['id'].toString();
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

    if (name.isEmpty || description.isEmpty || selectedLocation.isEmpty) {
      _showSnackBar('Por favor, complete todos los campos.');
      return;
    }

    final result = await createTask(
      name: name,
      description: description,
      selectedVolunteers: selectedVolunteers,
      selectedLocation: selectedLocation,
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
          _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Crear Tarea',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              _buildCreateButton(),
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

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _handleCreateTask,
        child: const Text('Crear Tarea'),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
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
                      value: selectedValue,
                      items:
                          items.map((item) {
                            final id = item['id']?.toString() ?? "";
                            final name =
                                item['name']?.toString() ?? "Sin nombre";
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                      onChanged: onChanged,
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
                final isSelected = selectedVolunteers.contains(volunteer['id']);
                return ListTile(
                  title: Text('${volunteer['name']} ${volunteer['surname']}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedVolunteers.add(volunteer['id']);
                        } else {
                          selectedVolunteers.remove(volunteer['id']);
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
