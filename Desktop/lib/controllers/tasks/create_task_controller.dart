import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/services/location_external_services.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/services/victim_services.dart';
import 'package:solidarityhub/services/volunteer_services.dart';

class CreateTaskController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController searchAddressController = TextEditingController();
  final TextEditingController searchVolunteersController = TextEditingController();
  final TextEditingController searchVictimController = TextEditingController();

  final MapController mapController = MapController();
  final TaskWithDetails? taskToEdit;
  final VoidCallback onTaskCreated;

  DateTime? startDate;
  DateTime? endDate;
  List<Marker> markers = [];
  LatLng selectedLocation = const LatLng(39.4699, -0.3776);
  List<Volunteer> volunteers = [];
  List<Victim> victims = [];
  List<int> selectedVolunteers = [];
  List<int> selectedVictim = [];
  bool isLoading = true;

  CreateTaskController({required this.onTaskCreated, this.taskToEdit}) {
    _initialize();
  }

  void _initialize() {
    startDate = DateTime.now();

    if (taskToEdit != null) {
      nameController.text = taskToEdit!.name;
      descriptionController.text = taskToEdit!.description;
      startDate = taskToEdit!.startDate;
      endDate = taskToEdit!.endDate;
      selectedVolunteers = taskToEdit!.assignedVolunteers.map((volunteer) => volunteer.id).toList();
      selectedVictim = taskToEdit!.assignedVictim.map((victim) => victim.id).toList();
    } else {
      _updateLocationControllers(selectedLocation);
      _updateMarker(selectedLocation);
    }
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    searchAddressController.dispose();
    searchVolunteersController.dispose();
    searchVictimController.dispose();
  }

  void updateLocationControllers(LatLng location) {
    _updateLocationControllers(location);
  }

  void _updateLocationControllers(LatLng location) {
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
  }

  void updateMarker(LatLng location) {
    _updateMarker(location);
  }

  void _updateMarker(LatLng location) {
    markers = [
      Marker(point: location, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
    ];
  }

  void onMapTap(TapPosition tapPosition, LatLng location) {
    selectedLocation = location;
    _updateLocationControllers(location);
    _updateMarker(location);
  }

  Future<void> loadTaskLocation() async {
    if (taskToEdit != null) {
      try {
        final url = Uri.parse('http://localhost:5170/api/v1/locations/${taskToEdit!.locationId}');
        final response = await http.get(url);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          final location = json.decode(response.body);
          final latLng = LatLng(
            double.parse(location['latitude'].toString()),
            double.parse(location['longitude'].toString()),
          );
          selectedLocation = latLng;
          _updateLocationControllers(latLng);
          _updateMarker(latLng);
        }
      } catch (error) {
        throw Exception('Error loading location: $error');
      }
    }
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        VolunteerServices.fetchVolunteersWithDetails(),
        VictimServices.fetchAllVictims(),
      ]);

      volunteers = results[0] as List<Volunteer>;
      victims = results[1] as List<Victim>;
      isLoading = false;

      if (taskToEdit != null) {
        await loadTaskLocation();
      }
    } catch (error) {
      isLoading = false;
      throw Exception(error.toString());
    }
  }

  Future<String> handleCreateTask() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final latitude = latitudeController.text.trim();
    final longitude = longitudeController.text.trim();

    if (startDate == null) {
      return 'Por favor, selecciona una fecha de inicio';
    }

    try {
      final result = await TaskServices.createTask(
        name: name,
        description: description,
        selectedVolunteers: selectedVolunteers,
        latitude: latitude,
        longitude: longitude,
        startDate: startDate!,
        endDate: endDate,
        selectedVictim: selectedVictim,
        taskId: taskToEdit?.id,
      );

      if (result.startsWith('OK:')) {
        onTaskCreated();
        return 'success';
      } else {
        return result;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<void> searchAddress() async {
    final address = searchAddressController.text.trim();
    final locationCoords = await LocationExternalServices.getLatLonFromAddress(address);
    selectedLocation = locationCoords?['location'] as LatLng;
    mapController.move(selectedLocation, locationCoords?['zoomLevel'] ?? 15.0);

    _updateLocationControllers(selectedLocation);
    _updateMarker(selectedLocation);
    mapController.move(selectedLocation, 15.0);
  }

  List<Volunteer> filteredVolunteers() {
    if (searchVolunteersController.text.isEmpty) {
      return volunteers;
    }
    final query = searchVolunteersController.text.toLowerCase();
    return volunteers.where((volunteer) {
      return volunteer.name.toLowerCase().contains(query) ||
          volunteer.surname.toLowerCase().contains(query) ||
          volunteer.email.toLowerCase().contains(query);
    }).toList();
  }

  List<Victim> filteredVictim() {
    if (searchVictimController.text.isEmpty) {
      return victims;
    }
    final query = searchVictimController.text.toLowerCase();
    return victims.where((person) {
      return person.name.toLowerCase().contains(query) ||
          person.surname.toLowerCase().contains(query) ||
          person.email.toLowerCase().contains(query);
    }).toList();
  }

  void toggleVolunteerSelection(int volunteerId, bool isSelected) {
    if (isSelected) {
      selectedVolunteers.add(volunteerId);
    } else {
      selectedVolunteers.remove(volunteerId);
    }
  }

  void toggleVictimSelection(int victimId, bool isSelected) {
    if (isSelected) {
      selectedVictim.add(victimId);
    } else {
      selectedVictim.remove(victimId);
    }
  }

  void setStartDate(DateTime date) {
    startDate = date;
  }

  void setEndDate(DateTime? date) {
    endDate = date;
  }
}
