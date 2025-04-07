import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

Future<String> createTask(String name, String description) async {
  final url = Uri.parse("http://localhost:5170/api/v1/tasks");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "description": description,
        "admin_id": 1,
        "location_id": 1,
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

class _CreateTaskState extends State<CreateTask>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameController.text;
                  final description = descriptionController.text;

                  if (name.isNotEmpty && description.isNotEmpty) {
                    final result = await createTask(name, description);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
