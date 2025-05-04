import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicBusiness/services/donationService.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/LogicPresentation/donations/assign_donation_dialog.dart';
import 'package:solidarityhub/LogicPresentation/donations/create_donation_dialog.dart';

class PhysicalDonationsTab extends StatefulWidget {
  final String baseUrl;
  final DonationService service;
  final List<Donation> donations;
  final List<Volunteer> volunteers;
  final bool isLoading;
  final String? errorMessage;
  final Function() onRefresh;
  final Function(Donation) onDonationCreated;
  final Function(Donation) onDonationAssigned;

  const PhysicalDonationsTab({
    Key? key,
    required this.baseUrl,
    required this.service,
    required this.donations,
    required this.volunteers,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onDonationCreated,
    required this.onDonationAssigned,
  }) : super(key: key);

  @override
  _PhysicalDonationsTabState createState() => _PhysicalDonationsTabState();
}

class _PhysicalDonationsTabState extends State<PhysicalDonationsTab> {
  Volunteer? _selectedFilterVolunteer;
  PhysicalDonationType? _selectedFilterCategory;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  RangeValues _quantityRange = const RangeValues(0, 100);
  bool _showFilters = false;

  List<Donation> _getFilteredDonations() {
    return widget.donations.where((donation) {
      if (_selectedFilterVolunteer != null && donation.volunteer?.id != _selectedFilterVolunteer?.id) {
        return false;
      }
      if (_selectedFilterCategory != null && donation.category != _selectedFilterCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty && !donation.itemName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedDateRange != null &&
          (donation.donationDate.isBefore(_selectedDateRange!.start) ||
              donation.donationDate.isAfter(_selectedDateRange!.end))) {
        return false;
      }
      if (donation.donated < _quantityRange.start || donation.donated > _quantityRange.end) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _showCreateDonationDialog() async {
    if (widget.volunteers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay voluntarios disponibles')));
      }
      return;
    }

    final result = await showDialog<Donation>(
      context: context,
      builder: (context) => CreateDonationDialog(volunteers: widget.volunteers),
    );

    if (result != null && mounted) {
      try {
        final createdDonation = await widget.service.createDonation(result);
        widget.onDonationCreated(createdDonation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donación creada con éxito')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear la donación: $e')));
        }
      }
    }
  }

  Future<void> _showAssignDonationDialog(Donation donation) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AssignDonationDialog(
            baseUrl: widget.baseUrl,
            availableDonations: widget.donations.where((d) => !d.isFullyDistributed).toList(),
            selectedDonation: donation,
          ),
    );

    if (result != null) {
      try {
        final updatedDonation = await widget.service.assignDonation(
          result['donation'].id,
          result['victim'].id,
          result['quantity'],
          result['date'],
        );
        widget.onDonationAssigned(updatedDonation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donación asignada correctamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al asignar donación: $e')));
        }
      }
    }
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(hintText: 'Buscar por nombre...', prefixIcon: Icon(Icons.search)),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ],
        ),
        if (_showFilters) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<Volunteer>(
            value: _selectedFilterVolunteer,
            decoration: const InputDecoration(labelText: 'Filtrar por voluntario'),
            items: [
              const DropdownMenuItem<Volunteer>(value: null, child: Text('Todos')),
              ...widget.volunteers.map((v) => DropdownMenuItem(value: v, child: Text('${v.name} ${v.surname}'))),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilterVolunteer = value;
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PhysicalDonationType>(
            value: _selectedFilterCategory,
            decoration: const InputDecoration(labelText: 'Filtrar por categoría'),
            items: [
              const DropdownMenuItem<PhysicalDonationType>(value: null, child: Text('Todas')),
              ...PhysicalDonationType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name))),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilterCategory = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDonationCard(Donation donation) {
    final bool isAssigned = donation.assignedVictim != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation.itemName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(donation.category.name, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                if (isAssigned)
                  const Chip(
                    label: Text('Asignado', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  )
                else
                  ElevatedButton(
                    onPressed: () => _showAssignDonationDialog(donation),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Asignar'),
                  ),
              ],
            ),
            const Divider(),
            Text(donation.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cantidad: ${donation.donated}', style: const TextStyle(fontSize: 16)),
                if (donation.distributed > 0)
                  Text('Distribuido: ${donation.distributed}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            if (donation.volunteer != null) ...[
              const SizedBox(height: 8),
              Text(
                'Voluntario: ${donation.volunteer!.name} ${donation.volunteer!.surname}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            if (isAssigned) ...[
              const SizedBox(height: 8),
              Text(
                'Asignado a: ${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.errorMessage!),
            ElevatedButton(onPressed: widget.onRefresh, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final filteredDonations = _getFilteredDonations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterBar(),
          const SizedBox(height: 16),
          if (filteredDonations.isEmpty)
            const Center(
              child: Text('No hay donaciones disponibles', style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDonations.length,
              itemBuilder: (context, index) => _buildDonationCard(filteredDonations[index]),
            ),
        ],
      ),
    );
  }
}
