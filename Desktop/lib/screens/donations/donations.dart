import 'package:flutter/material.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/widgets/donations/assign_donation_dialog.dart';
import 'package:solidarityhub/widgets/donations/create_donation_dialog.dart';
import 'package:solidarityhub/widgets/donations/create_monetary_donation_dialog.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/services/donation_services.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/utils/logger.dart';
import 'package:solidarityhub/screens/donations/tabs/monetary_donations_tab.dart';
import 'package:solidarityhub/screens/donations/resume_sections.dart';

class DonationsPage extends StatefulWidget {
  final String baseUrl;
  const DonationsPage({Key? key, required this.baseUrl}) : super(key: key);

  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Donation> _donations = [];
  List<MonetaryDonation> _monetaryDonations = [];
  List<Volunteer> _volunteers = [];
  bool _isLoading = true;
  String? _errorMessage;

  Volunteer? _selectedFilterVolunteer;
  PhysicalDonationType? _selectedFilterCategory;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  RangeValues _quantityRange = const RangeValues(0, 100);
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchDonations();
    _fetchMonetaryDonations();
    _fetchVolunteers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDonations() async {
    try {
      final donations = await Logger.runAsync(() => DonationServices.fetchAllDonations(), 'fetchDonations');
      if (mounted) {
        setState(() {
          _donations = donations;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMonetaryDonations() async {
    try {
      final donations = await Logger.runAsync(
        () => DonationServices.fetchAllMonetaryDonations(),
        'fetchMonetaryDonations',
      );
      if (mounted) {
        setState(() {
          _monetaryDonations = donations;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchVolunteers() async {
    try {
      final volunteers = await Logger.runAsync(() => VolunteerServices.fetchVolunteers(), 'fetchVolunteers');
      if (mounted) {
        setState(() {
          _volunteers = volunteers.cast<Volunteer>();
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void handleDonationCreated(Donation donation) {
    setState(() {
      _donations.add(donation);
      _errorMessage = null;
    });
  }

  void handleDonationAssigned(Donation donation) {
    setState(() {
      final index = _donations.indexWhere((d) => d.id == donation.id);
      if (index != -1) {
        _donations[index] = donation;
      }
      _errorMessage = null;
    });
  }

  IconData _iconForCategory(PhysicalDonationType type) {
    switch (type) {
      case PhysicalDonationType.Food:
        return Icons.fastfood;
      case PhysicalDonationType.Tools:
        return Icons.build;
      case PhysicalDonationType.Clothes:
        return Icons.checkroom;
      case PhysicalDonationType.Medicine:
        return Icons.local_hospital;
      case PhysicalDonationType.Furniture:
        return Icons.chair;
      default:
        return Icons.category;
    }
  }

  Future<void> _deleteDonation(Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Está seguro de que desea eliminar la donación "${donation.itemName}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await DonationServices.deleteDonation(donation.id);
        await _fetchDonations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donación eliminada correctamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showCreateDonationDialog() async {
    if (_volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay voluntarios disponibles para crear donaciones'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newDonation = await showDialog<Donation>(
      context: context,
      builder: (context) => CreateDonationDialog(volunteers: _volunteers),
    );

    if (newDonation != null && mounted) {
      try {
        await DonationServices.createDonation(newDonation);
        await _fetchDonations();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Donación creada correctamente'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
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
            availableDonations: _donations.where((d) => !d.isFullyDistributed).toList(),
            selectedDonation: donation,
          ),
    );

    if (result != null && mounted) {
      try {
        final selectedDonation = result['donation'] as Donation;
        final selectedVictim = result['victim'] as Victim;
        final quantity = result['quantity'] as int;
        final selectedDate = result['date'] as DateTime;

        await DonationServices.assignDonation(selectedDonation.id, selectedVictim.id, quantity, selectedDate);
        await _fetchDonations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donación asignada correctamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showDateRangeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTimeRange tempDateRange =
            _selectedDateRange ??
            DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());

        return AlertDialog(
          title: const Text('Seleccionar rango de fechas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Fecha inicial'),
                subtitle: Text(tempDateRange.start.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today, color: Colors.red),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: tempDateRange.start,
                    firstDate: DateTime(2020),
                    lastDate: tempDateRange.end,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.red, onPrimary: Colors.white)),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    tempDateRange = DateTimeRange(start: picked, end: tempDateRange.end);
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              ListTile(
                title: const Text('Fecha final'),
                subtitle: Text(tempDateRange.end.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today, color: Colors.red),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: tempDateRange.end,
                    firstDate: tempDateRange.start,
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.red, onPrimary: Colors.white)),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    tempDateRange = DateTimeRange(start: tempDateRange.start, end: picked);
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Limpiar filtro'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDateRange = tempDateRange;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonationCard(Donation r) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconForCategory(r.category), size: 32, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.itemName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(r.category.name, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Total: ${r.donated}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      Text(
                        'Disponible: ${r.availableQuantity}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  if (r.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.description, style: const TextStyle(fontSize: 14)),
                  ],
                  if (r.volunteer != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Donado por: ${r.volunteer!.name} ${r.volunteer!.surname}',
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                if (!r.isFullyDistributed)
                  ElevatedButton(
                    onPressed: () => _showAssignDonationDialog(r),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Asignar'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _deleteDonation(r),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Donation> _getFilteredDonations() {
    List<Donation> filtered = _donations;

    // Aplicar filtros
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (d) =>
                    d.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    d.description.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    if (_selectedFilterVolunteer != null) {
      filtered = filtered.where((d) => d.volunteer?.id == _selectedFilterVolunteer!.id).toList();
    }

    if (_selectedFilterCategory != null) {
      filtered = filtered.where((d) => d.category == _selectedFilterCategory).toList();
    }

    if (_selectedDateRange != null) {
      filtered =
          filtered
              .where(
                (d) =>
                    d.donationDate.isAfter(_selectedDateRange!.start) &&
                    d.donationDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))),
              )
              .toList();
    }

    filtered = filtered.where((d) => d.donated >= _quantityRange.start && d.donated <= _quantityRange.end).toList();

    return filtered;
  }

  // Método para agrupar donaciones por víctima
  Map<String, List<Donation>> _groupDonationsByVictim(List<Donation> donations) {
    final Map<String, List<Donation>> grouped = {};

    for (var donation in donations) {
      if (donation.assignedVictim != null) {
        final victimKey = '${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}';
        if (!grouped.containsKey(victimKey)) {
          grouped[victimKey] = [];
        }
        grouped[victimKey]!.add(donation);
      }
    }

    return grouped;
  }

  Future<void> _deleteAssignment(Donation donation) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: Text('¿Eliminar la asignación de "${donation.itemName}" a ${donation.assignedVictim!.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Eliminar'),
                  ),
                ],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await DonationServices.unassignDonation(donation.id);
      await _fetchDonations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignación eliminada correctamente')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar la asignación: $e')));
      }
    }
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Historial de Asignaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _showDateRangeDialog,
                icon: const Icon(Icons.calendar_today, color: Colors.red),
                label: Text(
                  _selectedDateRange != null
                      ? '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}'
                      : 'Filtrar por fecha',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildVictimsList(_getFilteredDonationsForHistory()),
      ],
    );
  }

  List<Donation> _getFilteredDonationsForHistory() {
    List<Donation> filtered = _donations.where((d) => d.assignedVictim != null).toList();

    if (_selectedDateRange != null) {
      filtered =
          filtered
              .where(
                (d) =>
                    d.donationDate.isAfter(_selectedDateRange!.start) &&
                    d.donationDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))),
              )
              .toList();
    }

    // Ordenar por fecha más reciente primero
    filtered.sort((a, b) => b.donationDate.compareTo(a.donationDate));

    return filtered;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Widget _buildVictimsList(List<Donation> filteredDonations) {
    if (filteredDonations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay donaciones asignadas', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    final groupedDonations = _groupDonationsByVictim(filteredDonations);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedDonations.length,
      itemBuilder: (context, index) {
        final victimName = groupedDonations.keys.elementAt(index);
        final victimDonations = groupedDonations[victimName]!;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Asignado a: $victimName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: victimDonations.length,
                itemBuilder: (context, donationIndex) {
                  final donation = victimDonations[donationIndex];
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(_iconForCategory(donation.category), color: Colors.red),
                        title: Text(
                          '${donation.itemName} (${donation.distributed} de ${donation.donated})',
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (donation.volunteer != null)
                              Text(
                                'Donado por: ${donation.volunteer!.name} ${donation.volunteer!.surname}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            Text(
                              'Asignado: ${_formatDate(donation.donationDate)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (donation.isFullyDistributed)
                              const Chip(
                                label: Text('Completado'),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                              )
                            else
                              const Chip(
                                label: Text('Parcial'),
                                backgroundColor: Colors.orange,
                                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAssignment(donation),
                              tooltip: 'Eliminar asignación',
                            ),
                          ],
                        ),
                      ),
                      if (donationIndex < victimDonations.length - 1) const Divider(height: 1, indent: 72),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
          if (_showFilters) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Barra de búsqueda
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o descripción',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro de voluntarios
                  DropdownButtonFormField<Volunteer?>(
                    value: _selectedFilterVolunteer,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por voluntario',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos los voluntarios')),
                      ..._volunteers
                          .map((v) => DropdownMenuItem(value: v, child: Text('${v.name} ${v.surname}')))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilterVolunteer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro de categoría
                  DropdownButtonFormField<PhysicalDonationType?>(
                    value: _selectedFilterCategory,
                    decoration: const InputDecoration(labelText: 'Filtrar por categoría', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas las categorías')),
                      ...PhysicalDonationType.values
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.name)))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilterCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro de cantidad
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rango de cantidad'),
                      RangeSlider(
                        values: _quantityRange,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        labels: RangeLabels(
                          _quantityRange.start.round().toString(),
                          _quantityRange.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _quantityRange = values;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedFilterVolunteer = null;
                            _selectedFilterCategory = null;
                            _selectedDateRange = null;
                            _quantityRange = const RangeValues(0, 100);
                          });
                        },
                        child: const Text('Limpiar filtros'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumeSection() {
    final types = [
      PhysicalDonationType.Food,
      PhysicalDonationType.Tools,
      PhysicalDonationType.Clothes,
      PhysicalDonationType.Medicine,
      PhysicalDonationType.Furniture,
    ];

    return SizedBox(
      height: 130,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 30.0;
          const itemSpacing = 26.0;
          final totalPadding = horizontalPadding * 2;
          final totalSpacing = itemSpacing * (types.length - 1);
          // ancho máximo disponible para todas las tarjetas
          final availableWidth = constraints.maxWidth - totalPadding - totalSpacing;
          // ancho por tarjeta para que quepan exactamente 5 adaptándose al ancho de pantalla
          final cardWidth = availableWidth / types.length;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: List.generate(types.length, (index) {
                final type = types[index];
                final list = _donations.where((d) => d.category == type);
                final available = list.fold<int>(0, (sum, d) => sum + d.availableQuantity);
                final assigned = list.fold<int>(0, (sum, d) => sum + d.distributed);

                String title;
                switch (type) {
                  case PhysicalDonationType.Food:
                    title = 'Comida';
                    break;
                  case PhysicalDonationType.Tools:
                    title = 'Herramientas';
                    break;
                  case PhysicalDonationType.Clothes:
                    title = 'Ropa';
                    break;
                  case PhysicalDonationType.Medicine:
                    title = 'Medicinas';
                    break;
                  case PhysicalDonationType.Furniture:
                    title = 'Mobiliario';
                    break;
                  default:
                    title = type.name;
                    break;
                }

                return Padding(
                  padding: EdgeInsets.only(right: index < types.length - 1 ? itemSpacing : 0),
                  child: SizedBox(
                    width: cardWidth,
                    child: DonationSummaryCard(
                      title: title,
                      available: available,
                      assigned: assigned,
                      icon: _iconForCategory(type),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donaciones'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Donaciones Físicas'), Tab(text: 'Donaciones Monetarias')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPhysicalDonationsTab(), _buildMonetaryDonationsTab()],
      ),
    );
  }

  Widget _buildPhysicalDonationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(_errorMessage!), ElevatedButton(onPressed: _fetchDonations, child: const Text('Reintentar'))],
        ),
      );
    }

    final filteredDonations = _getFilteredDonations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Donaciones Físicas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showCreateDonationDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva Donación', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResumeSection(),
          const SizedBox(height: 16),
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
          const SizedBox(height: 32),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildMonetaryDonationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(onPressed: _fetchMonetaryDonations, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return MonetaryDonationsTab(
      donations: _monetaryDonations,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRefresh: _fetchMonetaryDonations,
      volunteers: _volunteers,
    );
  }

  Future<void> _showCreateMonetaryDonationDialog() async {
    final result = await showDialog<MonetaryDonation>(
      context: context,
      builder: (context) => CreateMonetaryDonationDialog(volunteers: _volunteers),
    );

    if (result != null) {
      try {
        final createdDonation = await DonationServices.createMonetaryDonation(result);
        setState(() {
          _monetaryDonations.add(createdDonation);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Donación monetaria creada exitosamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la donación monetaria: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
