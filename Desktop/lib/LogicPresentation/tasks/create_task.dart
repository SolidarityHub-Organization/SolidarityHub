import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/LogicBusiness/handlers/task_handler.dart';
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
  required String latitude,
  required String longitude,
  int? taskId,
}) async {
  final Map<String, dynamic> taskData = {
    "id": taskId,
    "name": name,
    "description": description,
    "admin_id": null,
    "volunteer_ids": selectedVolunteers,
    "location": {"latitude": latitude, "longitude": longitude},
  };

  final validationHandler = ValidationHandler();
  final locationHandler = LocationHandler();
  final persistenceHandler = PersistenceHandler();

  validationHandler.setNext(locationHandler).setNext(persistenceHandler);

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

  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng selectedLocation = const LatLng(
    39.4699,
    -0.3776,
  ); // Valencia por defecto
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
      _updateLocationControllers(selectedLocation);
      _updateMarker(selectedLocation);
    }
  }

  void _updateLocationControllers(LatLng location) {
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers = [
        Marker(
          point: location,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ];
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      selectedLocation = location;
      _updateLocationControllers(location);
      _updateMarker(location);
    });
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
          final latLng = LatLng(
            double.parse(location['latitude'].toString()),
            double.parse(location['longitude'].toString()),
          );
          setState(() {
            selectedLocation = latLng;
            _updateLocationControllers(latLng);
            _updateMarker(latLng);
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
    final latitude = latitudeController.text.trim();
    final longitude = longitudeController.text.trim();

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
      if (mounted) {
        Navigator.pop(context);
      }
    }

    AppSnackBar.show(
      context: context,
      message: result,
      type: result.startsWith("OK") ? SnackBarType.success : SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
        borderRadius: BorderRadius.circular(8.0),
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: nameController,
                  label: 'Nombre',
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: descriptionController,
                  label: 'Descripción',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildLocationFields(),
                const SizedBox(height: 8),
                _buildCreateButton(widget.taskToEdit != null),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildVolunteerList()),
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
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 13,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: latitudeController,
                label: 'Latitud',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) {
                  try {
                    final lat = double.parse(value);
                    final newLocation = LatLng(lat, selectedLocation.longitude);
                    setState(() {
                      selectedLocation = newLocation;
                      _updateMarker(newLocation);
                    });
                  } catch (e) {
                    // Ignorar errores de parsing
                  }
                },
                maxLines: 1,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: longitudeController,
                label: 'Longitud',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) {
                  try {
                    final lng = double.parse(value);
                    final newLocation = LatLng(selectedLocation.latitude, lng);
                    setState(() {
                      selectedLocation = newLocation;
                      _updateMarker(newLocation);
                    });
                  } catch (e) {
                    // Ignorar errores de parsing
                  }
                },
                maxLines: 1,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolunteerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voluntarios disponibles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = volunteers[index];
              final isSelected = selectedVolunteers.contains(volunteer.id);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: 0,
                color: isSelected ? Colors.red.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: isSelected ? Colors.red : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    '${volunteer.name} ${volunteer.surname}',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Checkbox(
                    activeColor: Colors.red,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    EdgeInsets? contentPadding,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
    );
  }

  Widget _buildCreateButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: _handleCreateTask,
        icon: Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white),
        label: Text(
          isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
