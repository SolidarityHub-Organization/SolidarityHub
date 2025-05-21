import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:solidarityhub/models/task.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/models/skill.dart';
import 'package:solidarityhub/services/location_external_services.dart';
import 'package:solidarityhub/services/location_services.dart';
import 'package:solidarityhub/services/task_services.dart';
import 'package:solidarityhub/services/victim_services.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/services/need_services.dart';

class CreateTaskController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController searchAddressController = TextEditingController();
  final TextEditingController searchVolunteersController = TextEditingController();
  final TextEditingController searchSkillsController = TextEditingController();
  final TextEditingController searchVictimController = TextEditingController();
  final TextEditingController searchNeedsController = TextEditingController();

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

  Map<int, Map<String, dynamic>> victimNeeds = {};

  List<Skill> get availableSkills {
    final Set<int> skillIds = {};
    final List<Skill> uniqueSkills = [];

    for (var volunteer in volunteers) {
      for (var skill in volunteer.skills) {
        if (!skillIds.contains(skill.id)) {
          skillIds.add(skill.id);
          uniqueSkills.add(skill);
        }
      }
    }

    return uniqueSkills;
  }

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
    searchSkillsController.dispose();
    searchVictimController.dispose();
    searchNeedsController.dispose();
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
      final location = await LocationServices.fetchLocationById(taskToEdit!.locationId);

      if (location.isNotEmpty) {
        final latLng = LatLng(
          double.parse(location['latitude'].toString()),
          double.parse(location['longitude'].toString()),
        );
        selectedLocation = latLng;
        _updateLocationControllers(latLng);
        _updateMarker(latLng);
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

      for (var victim in victims) {
        await fetchVictimNeeds(victim.id);
      }

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
    if (searchVolunteersController.text.isEmpty && searchSkillsController.text.isEmpty) {
      return volunteers;
    }

    final nameQuery = searchVolunteersController.text.toLowerCase();
    final skillsQuery = searchSkillsController.text.toLowerCase();

    return volunteers.where((volunteer) {
      // Filtrado por datos personales
      final matchesSearch =
          searchVolunteersController.text.isEmpty ||
          volunteer.name.toLowerCase().contains(nameQuery) ||
          volunteer.surname.toLowerCase().contains(nameQuery) ||
          volunteer.email.toLowerCase().contains(nameQuery);

      // Filtrado por habilidades
      bool matchesSkills = true;
      if (skillsQuery.isNotEmpty) {
        if (volunteer.skills.isEmpty) {
          matchesSkills = false;
        } else {
          matchesSkills = volunteer.skills.any((skill) {
            // Busca coincidencias en el nombre de la habilidad
            return skill.name.toLowerCase().contains(skillsQuery);
          });
        }
      }

      return matchesSearch && matchesSkills;
    }).toList();
  }

  List<Victim> filteredVictim() {
    if (searchVictimController.text.isEmpty && searchNeedsController.text.isEmpty) {
      return victims;
    }

    final personQuery = searchVictimController.text.toLowerCase();
    final needsQuery = searchNeedsController.text.toLowerCase();

    return victims.where((person) {
      // Filtrado por datos personales
      final matchesPerson =
          searchVictimController.text.isEmpty ||
          person.name.toLowerCase().contains(personQuery) ||
          person.surname.toLowerCase().contains(personQuery) ||
          person.email.toLowerCase().contains(personQuery);

      // Filtrado por necesidades
      bool matchesNeeds = true;
      if (needsQuery.isNotEmpty && victimNeeds.containsKey(person.id)) {
        final need = victimNeeds[person.id]!;
        if (need.containsKey('name')) {
          matchesNeeds = need['name'].toString().toLowerCase().contains(needsQuery);
        } else if (need.containsKey('needs') && need['needs'] is List) {
          final List<dynamic> needsList = need['needs'];
          matchesNeeds = needsList.any(
            (item) =>
                item is Map<String, dynamic> &&
                item.containsKey('name') &&
                item['name'].toString().toLowerCase().contains(needsQuery),
          );
        } else {
          matchesNeeds = false;
        }
      } else if (needsQuery.isNotEmpty) {
        matchesNeeds = false;
      }

      return matchesPerson && matchesNeeds;
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

  Future<Map<String, dynamic>> fetchVictimNeeds(int victimId) async {
    if (victimNeeds.containsKey(victimId)) {
      return victimNeeds[victimId]!;
    }

    final needs = await NeedServices.fetchNeedByVictimId(victimId);

    if (needs.isNotEmpty) {
      victimNeeds[victimId] = needs;
      return needs;
    }

    return {};
  }

  String getFormattedNeedsForVictim(int victimId) {
    if (!victimNeeds.containsKey(victimId) || victimNeeds[victimId]!.isEmpty) {
      return 'Sin necesidades registradas';
    }

    final Map<String, dynamic> need = victimNeeds[victimId]!;

    if (need.containsKey('name')) {
      return need['name'].toString();
    }

    if (need.containsKey('needs') && need['needs'] is List) {
      final List<dynamic> needsList = need['needs'];
      if (needsList.isEmpty) {
        return 'Sin necesidades registradas';
      }

      final List<String> needNames = [];
      for (var item in needsList.take(2)) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          needNames.add(item['name'].toString());
        }
      }

      final String visibleNeeds = needNames.join(', ');

      if (needsList.length > 2) {
        return '$visibleNeeds...';
      }
      return visibleNeeds.isEmpty ? 'Sin necesidades registradas' : visibleNeeds;
    }

    // Fallback
    return 'Sin necesidades registradas';
  }

  void setStartDate(DateTime date) {
    startDate = date;
  }

  void setEndDate(DateTime? date) {
    endDate = date;
  }
}
