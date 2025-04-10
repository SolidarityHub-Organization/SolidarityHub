import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class TaskHandler {
  TaskHandler? nextHandler;

  TaskHandler setNext(TaskHandler handler) {
    nextHandler = handler;
    return handler;
  }

  Future<String> handle(Map<String, dynamic> taskData);
}

class ValidationHandler extends TaskHandler {
  @override
  Future<String> handle(Map<String, dynamic> taskData) async {
    if (taskData['name'].isEmpty || taskData['description'].isEmpty) {
      return "Error: Nombre y Descripción no pueden estar vacíos.";
    }

    final location = taskData['location'];

    try {
      final latitude = double.parse(location['latitude'].toString());
      final longitude = double.parse(location['longitude'].toString());
      if (latitude == 0 || longitude == 0) {
        return "Error: La ubicación debe seleccionarse.";
      }
    } catch (e) {
      return "Error: Latitud y Longitud deben ser números válidos.";
    }

    return nextHandler?.handle(taskData) ?? "Validación exitosa";
  }
}

class LocationHandler extends TaskHandler {
  @override
  Future<String> handle(Map<String, dynamic> taskData) async {
    final locationUrl = Uri.parse("http://localhost:5170/api/v1/locations");

    final locationResponse = await http.post(
      locationUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskData['location']),
    );

    if (locationResponse.statusCode < 200 ||
        locationResponse.statusCode > 299) {
      return "Error creating location: ${locationResponse.statusCode} - ${locationResponse.body}";
    }

    final locationResult = json.decode(locationResponse.body);
    taskData['location_id'] = locationResult['id'];

    return nextHandler?.handle(taskData) ?? "Ubicación creada con éxito";
  }
}

class PersistenceHandler extends TaskHandler {
  @override
  Future<String> handle(Map<String, dynamic> taskData) async {
    final isUpdate = taskData['id'] != null;

    final url =
        isUpdate
            ? Uri.parse("http://localhost:5170/api/v1/tasks/${taskData['id']}")
            : Uri.parse("http://localhost:5170/api/v1/tasks");

    final requestFn = isUpdate ? http.put : http.post;

    final response = await requestFn(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskData),
    );

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return isUpdate
          ? "OK: La tarea ha sido actualizada con éxito"
          : "OK: La tarea ha sido creada con éxito";
    } else {
      return "Persistence Error: ${response.statusCode} - ${response.body}";
    }
  }
}
