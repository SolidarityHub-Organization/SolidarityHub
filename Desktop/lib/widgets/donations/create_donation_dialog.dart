import 'package:flutter/material.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:flutter/services.dart';

class CreateDonationDialog extends StatefulWidget {
  final List<Volunteer> volunteers;

  const CreateDonationDialog({Key? key, required this.volunteers}) : super(key: key);

  @override
  _CreateDonationDialogState createState() => _CreateDonationDialogState();
}

class _CreateDonationDialogState extends State<CreateDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  PhysicalDonationType _selectedCategory = PhysicalDonationType.Other;
  Volunteer? _selectedVolunteer;

  @override
  void initState() {
    super.initState();
    if (widget.volunteers.isNotEmpty) {
      _selectedVolunteer = widget.volunteers.first;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Donación'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Nombre del recurso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una cantidad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  final quantity = int.parse(value);
                  if (quantity <= 0) {
                    return 'La cantidad debe ser mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PhysicalDonationType>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items:
                    PhysicalDonationType.values
                        .map((type) => DropdownMenuItem(value: type, child: Text(type.name)))
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Volunteer>(
                value: _selectedVolunteer,
                decoration: const InputDecoration(labelText: 'Voluntario'),
                items:
                    widget.volunteers
                        .map(
                          (volunteer) =>
                              DropdownMenuItem(value: volunteer, child: Text('${volunteer.name} ${volunteer.surname}')),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVolunteer = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un voluntario';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newDonation = Donation(
                id: 1000,
                itemName: _itemNameController.text,
                description: _descriptionController.text,
                category: _selectedCategory,
                donated: int.parse(_quantityController.text),
                volunteer: _selectedVolunteer,
              );
              Navigator.pop(context, newDonation);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
