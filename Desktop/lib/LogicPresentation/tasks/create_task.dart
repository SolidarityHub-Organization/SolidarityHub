import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solidarityhub/LogicBusiness/services/task_services.dart';
import 'package:solidarityhub/LogicPersistence/models/task.dart';
import 'package:solidarityhub/LogicPersistence/models/victim.dart';
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
  final TextEditingController searchAddressController = TextEditingController();
  final TextEditingController searchVolunteersController =
      TextEditingController();
  final TextEditingController searchVictimController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng selectedLocation = const LatLng(
    39.4699,
    -0.3776,
  ); // Valencia por defecto
  List<Volunteer> volunteers = [];
  List<Victim> victim = [];
  List<int> selectedVolunteers = [];
  List<int> selectedVictim = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    startDate = DateTime.now(); // Set default start date to current date

    if (widget.taskToEdit != null) {
      nameController.text = widget.taskToEdit!.name;
      descriptionController.text = widget.taskToEdit!.description;
      startDate = widget.taskToEdit!.startDate;
      endDate = widget.taskToEdit!.endDate;
      _loadTaskLocation();
      selectedVolunteers =
          widget.taskToEdit!.assignedVolunteers
              .map((volunteer) => volunteer.id)
              .toList();
      selectedVictim =
          widget.taskToEdit!.assignedVictim.map((victim) => victim.id).toList();
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
        fetchData("victims", Victim.fromJson),
      ]);
      setState(() {
        volunteers = results[0] as List<Volunteer>;
        victim = results[1] as List<Victim>;
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

    if (startDate == null) {
      AppSnackBar.show(
        context: context,
        message: "Por favor, selecciona una fecha de inicio",
        type: SnackBarType.error,
      );
      return;
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
        taskId: widget.taskToEdit?.id,
      );

      if (result.startsWith("OK:")) {
        widget.onTaskCreated();
        if (mounted) {
          Navigator.pop(context);
        }
        AppSnackBar.show(
          context: context,
          message:
              widget.taskToEdit != null
                  ? "Tarea actualizada correctamente"
                  : "Tarea creada correctamente",
          type: SnackBarType.success,
        );
      } else {
        AppSnackBar.show(
          context: context,
          message: result,
          type: SnackBarType.error,
        );
      }
    } catch (error) {
      AppSnackBar.show(
        context: context,
        message: "Error: $error",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _searchAddress() async {
    final address = searchAddressController.text.trim();
    if (address.isEmpty) {
      AppSnackBar.show(
        context: context,
        message: "Por favor, introduce una dirección para buscar",
        type: SnackBarType.error,
      );
      return;
    }

    try {
      // Encode the address for URL
      final encodedAddress = Uri.encodeComponent(address);
      // Use Nominatim geocoding service (OpenStreetMap)
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1",
      );

      final response = await http.get(
        url,
        headers: {"User-Agent": "SolidarityHub/1.0"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          final double lat = double.parse(result['lat']);
          final double lon = double.parse(result['lon']);
          final LatLng location = LatLng(lat, lon);

          setState(() {
            selectedLocation = location;
            _updateLocationControllers(location);
            _updateMarker(location);
            _mapController.move(
              location,
              15.0,
            ); // Zoom in to the found location
          });
        } else {
          AppSnackBar.show(
            context: context,
            message: "No se encontró ninguna ubicación con esa dirección",
            type: SnackBarType.warning,
          );
        }
      } else {
        AppSnackBar.show(
          context: context,
          message: "Error al buscar la dirección: ${response.statusCode}",
          type: SnackBarType.error,
        );
      }
    } catch (error) {
      AppSnackBar.show(
        context: context,
        message: "Error: $error",
        type: SnackBarType.error,
      );
    }
  }

  // Función para buscar voluntarios
  List<Volunteer> _filteredVolunteers() {
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

  // Función para buscar afectados
  List<Victim> _filteredVictim() {
    if (searchVictimController.text.isEmpty) {
      return victim;
    }
    final query = searchVictimController.text.toLowerCase();
    return victim.where((person) {
      return person.name.toLowerCase().contains(query) ||
          person.surname.toLowerCase().contains(query) ||
          person.email.toLowerCase().contains(query);
    }).toList();
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
              _buildDateFields(),
              const SizedBox(height: 8),
              Expanded(child: _buildLocationFields()),
              const SizedBox(height: 8),
              _buildCreateButton(widget.taskToEdit != null),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildVolunteerSection()),
              const SizedBox(height: 16),
              Expanded(child: _buildVictimSection()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fechas de la tarea',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Fecha de inicio',
                date: startDate,
                onDateSelected: (date) {
                  setState(() {
                    startDate = date;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Fecha de fin (opcional)',
                date: endDate,
                onDateSelected: (date) {
                  setState(() {
                    endDate = date;
                  });
                },
                isOptional: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : isOptional
                      ? 'No especificada'
                      : 'Selecciona una fecha',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
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
                controller: searchAddressController,
                label: 'Buscar dirección',
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _searchAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 2,
          child: Container(
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
        ),
      ],
    );
  }

  Widget _buildVolunteerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voluntarios disponibles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: searchVolunteersController,
          decoration: InputDecoration(
            labelText: 'Buscar voluntarios',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                searchVolunteersController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchVolunteersController.clear();
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredVolunteers().length,
              itemBuilder: (context, index) {
                final volunteer = _filteredVolunteers()[index];
                final isSelected = selectedVolunteers.contains(volunteer.id);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  elevation: 0,
                  color: isSelected ? Colors.red.withAlpha(26) : null,
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
                    subtitle: Text(volunteer.email),
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
        ),
      ],
    );
  }

  Widget _buildVictimSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Afectados disponibles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: searchVictimController,
          decoration: InputDecoration(
            labelText: 'Buscar afectados',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                searchVictimController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchVictimController.clear();
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredVictim().length,
              itemBuilder: (context, index) {
                final person = _filteredVictim()[index];
                final isSelected = selectedVictim.contains(person.id);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  elevation: 0,
                  color: isSelected ? Colors.red.withAlpha(26) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: isSelected ? Colors.red : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      '${person.name} ${person.surname}',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(person.email),
                    trailing: Checkbox(
                      activeColor: Colors.red,
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedVictim.add(person.id);
                          } else {
                            selectedVictim.remove(person.id);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
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
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        isDense: true,
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
