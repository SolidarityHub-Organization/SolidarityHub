import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to show the create task modal
Future<void> showCreateTaskModal(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => const CreateTaskModal(),
  );
}

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({super.key});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

Future<String> createTask(
  String name,
  String description,
  List<int> selectedVolunteers,
  String selectedLocation,
) async {
  final url = Uri.parse("http://localhost:5170/api/v1/tasks");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "description": description,
        "admin_id": 1,
        "location_id": selectedLocation,
        "volunteer_ids": selectedVolunteers,
      }),
    );

    print(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return "Task has been added";
    } else {
      return "Error requesting the endpoint: ${response.statusCode}";
    }
  } catch (error) {
    return "Error: $error";
  }
}

Future<List<Map<String, dynamic>>> fetchVolunteers() async {
  final url = Uri.parse("http://localhost:5170/api/v1/volunteers");

  try {
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Error fetching volunteers: ${response.statusCode}");
    }
  } catch (error) {
    throw Exception("Error: $error");
  }
}

Future<List<Map<String, dynamic>>> fetchLocations() async {
  final url = Uri.parse("http://localhost:5170/api/v1/locations");

  try {
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var test = List<Map<String, dynamic>>.from(json.decode(response.body));
      return test;
    } else {
      throw Exception("Error fetching locations: ${response.statusCode}");
    }
  } catch (error) {
    throw Exception("Error: $error");
  }
}

class _CreateTaskModalState extends State<CreateTaskModal>
    with SingleTickerProviderStateMixin {
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

    Future.wait([fetchVolunteers(), fetchLocations()])
        .then((results) {
          setState(() {
            volunteers = results[0];
            locations = results[1];
            if (locations.isNotEmpty) {
              selectedLocation = locations[0]['id'].toString();
            }
            isLoading = false;
          });
        })
        .catchError((error) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Task',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Task details
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Task Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Task Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final name = nameController.text;
                                    final description =
                                        descriptionController.text;

                                    if (name.isNotEmpty &&
                                        description.isNotEmpty &&
                                        selectedLocation.isNotEmpty) {
                                      final result = await createTask(
                                        name,
                                        description,
                                        selectedVolunteers,
                                        selectedLocation,
                                      );

                                      // Close the modal and show a message
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(result)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please fill all fields and select a location',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Create Task'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column - Selections
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location section
                              const Text(
                                'Ubicación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child:
                                    locations.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          child: Text(
                                            "No hay ubicaciones disponibles",
                                          ),
                                        )
                                        : DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value:
                                                selectedLocation.isEmpty &&
                                                        locations.isNotEmpty
                                                    ? locations[0]['id']
                                                        .toString()
                                                    : selectedLocation,
                                            items:
                                                locations.map((location) {
                                                  final id =
                                                      location['id']
                                                          ?.toString() ??
                                                      "";
                                                  final name =
                                                      location['name']
                                                          ?.toString() ??
                                                      "Sin nombre";

                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: id,
                                                    child: Text(name),
                                                  );
                                                }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedLocation = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 16),
                              // Volunteers section
                              const Text(
                                'Voluntarios disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: volunteers.length,
                                  itemBuilder: (context, index) {
                                    final volunteer = volunteers[index];
                                    final isSelected = selectedVolunteers
                                        .contains(volunteer['id']);
                                    return ListTile(
                                      title: Text(
                                        '${volunteer['name']} ${volunteer['surname']}',
                                      ),
                                      trailing: Checkbox(
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedVolunteers.add(
                                                volunteer['id'],
                                              );
                                            } else {
                                              selectedVolunteers.remove(
                                                volunteer['id'],
                                              );
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
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
