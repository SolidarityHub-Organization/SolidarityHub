import 'dart:convert';

import 'package:solidarityhub/services/api_general_service.dart';

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
      return 'Error: Nombre y Descripción no pueden estar vacíos.';
    }

    final location = taskData['location'];

    try {
      final latitude = double.parse(location['latitude'].toString());
      final longitude = double.parse(location['longitude'].toString());
      if (latitude == 0 || longitude == 0) {
        return 'Error: La ubicación debe seleccionarse.';
      }
    } catch (e) {
      return 'Error: Latitud y Longitud deben ser números válidos.';
    }

    return nextHandler?.handle(taskData) ?? 'Validación exitosa';
  }
}

class LocationHandler extends TaskHandler {
  @override
  Future<String> handle(Map<String, dynamic> taskData) async {
    final locationResponse = await ApiGeneralService.post('locations', body: json.encode(taskData['location']));

    if (locationResponse.statusCode.ok) {
      return 'Error creating location: ${locationResponse.statusCode} - ${locationResponse.body}';
    }

    final locationResult = json.decode(locationResponse.body);
    taskData['location_id'] = locationResult['id'];

    return nextHandler?.handle(taskData) ?? 'Ubicación creada con éxito';
  }
}

class PersistenceHandler extends TaskHandler {
  @override
  Future<String> handle(Map<String, dynamic> taskData) async {
    final isUpdate = taskData['id'] != null;
    final url = isUpdate ? 'tasks/${taskData['id']}' : 'tasks';
    final requestFn = isUpdate ? ApiGeneralService.put : ApiGeneralService.post;
    final response = await requestFn(url, body: json.encode(taskData));

    if (response.statusCode.ok) {
      return isUpdate ? 'OK: La tarea ha sido actualizada con éxito' : 'OK: La tarea ha sido creada con éxito';
    } else {
      return 'Persistence Error: ${response.statusCode} - ${response.body}';
    }
  }
}
