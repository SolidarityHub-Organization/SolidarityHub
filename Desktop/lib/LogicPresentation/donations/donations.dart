import 'package:flutter/material.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/LogicPresentation/donations/assign_donation_dialog.dart';
import 'package:solidarityhub/LogicPresentation/donations/create_donation_dialog.dart';
import 'package:solidarityhub/models/volunteer.dart';
import 'package:solidarityhub/services/donation_services.dart';
import 'package:solidarityhub/services/volunteer_services.dart';
import 'package:solidarityhub/utils/logger.dart';

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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void handleDonationCreated(Donation donation) {
    setState(() {
      _donations.add(donation);
    });
  }

  void handleDonationAssigned(Donation donation) {
    setState(() {
      final index = _donations.indexWhere((d) => d.id == donation.id);
      if (index != -1) {
        _donations[index] = donation;
      }
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
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: Text('¿Eliminar recurso "${donation.itemName}"?'),
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
      await DonationServices.deleteDonation(donation.id);
      await _fetchDonations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donación eliminada correctamente')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  Future<void> _showCreateDonationDialog() async {
    if (_volunteers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay voluntarios disponibles para crear donaciones')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donación creada correctamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donación asignada correctamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al asignar donación: $e')));
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
                        trailing:
                            donation.isFullyDistributed
                                ? const Chip(
                                  label: Text('Completado'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                                )
                                : const Chip(
                                  label: Text('Parcial'),
                                  backgroundColor: Colors.orange,
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _tabController.index == 0 ? _showCreateDonationDialog : null,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Donaciones Monetarias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_monetaryDonations.isEmpty)
            const Center(
              child: Text(
                'No hay donaciones monetarias disponibles',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _monetaryDonations.length,
              itemBuilder: (context, index) => _buildMonetaryDonationCard(_monetaryDonations[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildMonetaryDonationCard(MonetaryDonation donation) {
    String getCurrencySymbol(Currency currency) {
      switch (currency) {
        case Currency.EUR:
          return '€';
        case Currency.USD:
          return '\$';
        default:
          return '';
      }
    }

    Color getStatusColor(PaymentStatus status) {
      switch (status) {
        case PaymentStatus.Completed:
          return Colors.green;
        case PaymentStatus.Pending:
          return Colors.orange;
        case PaymentStatus.Failed:
          return Colors.red;
        case PaymentStatus.Refunded:
          return Colors.blue;
      }
    }

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
                Text(
                  '${getCurrencySymbol(donation.currency)}${donation.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(donation.paymentStatus.name, style: const TextStyle(color: Colors.white)),
                  backgroundColor: getStatusColor(donation.paymentStatus),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payment),
              title: Text('Método de pago: ${donation.paymentService.name}'),
              subtitle: Text('ID Transacción: ${donation.transactionId}'),
            ),
            if (donation.volunteer != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text('Donante: ${donation.volunteer!.name} ${donation.volunteer!.surname}'),
              ),
            if (donation.assignedVictim != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text('Asignado a: ${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}'),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text('Fecha: ${donation.donationDate.toLocal().toString().split('.')[0]}'),
            ),
          ],
        ),
      ),
    );
  }
}
