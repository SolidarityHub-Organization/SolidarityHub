import 'package:flutter/material.dart';
import 'package:solidarityhub/services/victim_services.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:intl/intl.dart';

class AssignDonationDialog extends StatefulWidget {
  final String baseUrl;
  final List<Donation> availableDonations;
  final Donation selectedDonation;

  const AssignDonationDialog({
    Key? key,
    required this.baseUrl,
    required this.availableDonations,
    required this.selectedDonation,
  }) : super(key: key);

  @override
  _AssignDonationDialogState createState() => _AssignDonationDialogState();
}

class _AssignDonationDialogState extends State<AssignDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  late Donation _selectedDonation;
  Victim? _selectedVictim;
  int _quantity = 1;
  List<Victim> _victims = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDonation = widget.selectedDonation;
    _fetchVictims();
  }

  Future<void> _fetchVictims() async {
    try {
      final response = await VictimService.fetchAllVictims();
      setState(() {
        _victims = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar víctimas: $e')));
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.red, onPrimary: Colors.white)),
          child: SizedBox(height: 400, width: 300, child: child!),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: const Text('Asignar Donación'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Donation>(
                value: _selectedDonation,
                decoration: const InputDecoration(labelText: 'Recurso', border: OutlineInputBorder()),
                items:
                    widget.availableDonations
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text('${d.itemName} (${d.availableQuantity} disponibles)'),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDonation = value;
                      _quantity = 1;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un recurso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Victim>(
                value: _selectedVictim,
                decoration: const InputDecoration(labelText: 'Afectado', border: OutlineInputBorder()),
                items: _victims.map((v) => DropdownMenuItem(value: v, child: Text('${v.name} ${v.surname}'))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVictim = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un afectado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 1;
                  });
                },
                validator: (value) {
                  final quantity = int.tryParse(value ?? '') ?? 0;
                  if (quantity <= 0) {
                    return 'La cantidad debe ser mayor que 0';
                  }
                  if (quantity > _selectedDonation.availableQuantity) {
                    return 'No hay suficientes unidades disponibles';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de asignación',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(text: _dateFormat.format(_selectedDate)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'donation': _selectedDonation,
                'victim': _selectedVictim,
                'quantity': _quantity,
                'date': _selectedDate,
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}
