import 'package:flutter/material.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/services/donation_services.dart';
import 'package:solidarityhub/utils/logger.dart';
import 'dart:math' as math;
import 'package:solidarityhub/widgets/common/two_dimensional_scroll_widget.dart';
import 'package:solidarityhub/widgets/common/custom_pie_chart.dart';
import 'package:solidarityhub/widgets/common/custom_bar_chart.dart';

class RecursosTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  
  const RecursosTab({
    Key? key, 
    required this.fechaInicio,
    required this.fechaFin,
  }) : super(key: key);

  @override
  _RecursosTabState createState() => _RecursosTabState();
}

class _RecursosTabState extends State<RecursosTab> {
  List<Donation> _physicalDonations = [];
  List<MonetaryDonation> _monetaryDonations = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool _unassignedExpanded = true;
  bool _assignedExpanded = true;
  bool _monetaryExpanded = true;
  
  late Future<double> _totalMoneyFuture;
  late Future<int> _totalResourcesFuture;
  late Future<int> _totalDonorsFuture;
  late Future<Map<String, int>> _donationsByTypeFuture;
  final ScrollController _pieChartScrollController = ScrollController();
  final ScrollController _barChartScrollController = ScrollController();


  String _selectedDonationType = 'physical';
  late Future<Map<String, double>> _weeklyDonationsFuture;
  
  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final startDate = _adjustStartDate(widget.fechaInicio);
    final endDate = _adjustEndDate(widget.fechaFin);
    
    _totalMoneyFuture = DonationServices.fetchTotalQuantityFiltered(
      startDate,
      endDate,
      currency: 'EUR',
    );

    _totalResourcesFuture = DonationServices.fetchTotalPhysicalDonationsQuantity(
      startDate,
      endDate,
    ).catchError((error) {
      print('Error fetching physical donations: $error');
      return 0;
    });

    _totalDonorsFuture = DonationServices.fetchTotalDonors(
      startDate,
      endDate,
    );

    _donationsByTypeFuture = DonationServices.fetchPhysicalDonationsTotalAmountByType(
      startDate,
      endDate,
    );

    _loadWeeklyDonationsData();
  }

  void _loadWeeklyDonationsData() {
    final startDate = _adjustStartDate(widget.fechaInicio);
    final endDate = _adjustEndDate(widget.fechaFin);
    
    if (_selectedDonationType == 'physical') {
      _weeklyDonationsFuture = DonationServices.fetchPhysicalDonationsSumByWeek(startDate, endDate);
    } else {
      _weeklyDonationsFuture = DonationServices.fetchMonetaryDonationsSumByWeek(startDate, endDate);
    }
  }
  
  @override
  void didUpdateWidget(RecursosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchData();
      _loadDashboardData();
    }
  }

  void _onDonationTypeChanged(String? newValue) {
    if (newValue != null && newValue != _selectedDonationType) {
      setState(() {
        _selectedDonationType = newValue;
        _loadWeeklyDonationsData();
      });
    }
  }
  
  @override
  void dispose() {
    _pieChartScrollController.dispose();
    _barChartScrollController.dispose();
    super.dispose();
  }
  
  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final startDate = _adjustStartDate(widget.fechaInicio);
      final endDate = _adjustEndDate(widget.fechaFin);
      
      // fetch physical and monetary donations in parallel
      final physicalDonationsFuture = Logger.runAsync(
        () => DonationServices.fetchAllDonations(), 
        'fetchDonations'
      );
      
      final monetaryDonationsFuture = Logger.runAsync(
        () => DonationServices.fetchAllMonetaryDonations(), 
        'fetchMonetaryDonations'
      );
        // wait for both to complete
      final results = await Future.wait([
        physicalDonationsFuture,
        monetaryDonationsFuture,
      ]);
      
      if (mounted) {
        setState(() {
          _physicalDonations = results[0] as List<Donation>;
          _monetaryDonations = results[1] as List<MonetaryDonation>;
          
          // filter by date range if provided
          if (widget.fechaInicio != null && widget.fechaFin != null) {
            _physicalDonations = _physicalDonations.where((donation) {
              return donation.donationDate.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
                     donation.donationDate.isBefore(endDate.add(const Duration(seconds: 1)));
            }).toList();
            
            _monetaryDonations = _monetaryDonations.where((donation) {
              return donation.donationDate.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
                     donation.donationDate.isBefore(endDate.add(const Duration(seconds: 1)));
            }).toList();
          }
          
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
      case PhysicalDonationType.Other:
        return Icons.category;
    }
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

  List<Donation> _getUnassignedDonations() {
    return _physicalDonations
        .where((d) => d.assignedVictim == null)
        .toList();
  }

  List<Donation> _getAssignedDonations() {
    return _physicalDonations
        .where((d) => d.assignedVictim != null)
        .toList();
  }
  Widget _buildUnassignedDonationsSection() {
    final unassignedDonations = _getUnassignedDonations();
    
    if (unassignedDonations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No hay donaciones físicas sin asignar en este periodo',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: unassignedDonations.length,
      itemBuilder: (context, index) {
        final donation = unassignedDonations[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    Icon(_iconForCategory(donation.category), color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        donation.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Disponible: ${donation.availableQuantity}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (donation.description.isNotEmpty) ...[
                      Text(donation.description),
                      const SizedBox(height: 8),
                    ],
                    if (donation.volunteer != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Donado por: ${donation.volunteer!.name} ${donation.volunteer!.surname}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Registrado: ${_formatDate(donation.donationDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildAssignedDonationsSection() {
    final assignedDonations = _getAssignedDonations();
    
    if (assignedDonations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No hay donaciones físicas asignadas en este periodo',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // group donations by victim
    final groupedDonations = <String, List<Donation>>{};
    for (var donation in assignedDonations) {
      if (donation.assignedVictim != null) {
        final victimKey = '${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}';
        if (!groupedDonations.containsKey(victimKey)) {
          groupedDonations[victimKey] = [];
        }
        groupedDonations[victimKey]!.add(donation);
      }
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedDonations.length,
      itemBuilder: (context, index) {
        final victimName = groupedDonations.keys.elementAt(index);
        final victimDonations = groupedDonations[victimName]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Asignado a: $victimName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${victimDonations.length} ${victimDonations.length == 1 ? 'donación' : 'donaciones'}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: victimDonations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, donationIndex) {
                  final donation = victimDonations[donationIndex];
                  return ListTile(
                    leading: Icon(_iconForCategory(donation.category), color: Colors.green),
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
                    trailing: donation.isFullyDistributed 
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildMonetaryDonationsSection() {
    if (_monetaryDonations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No hay donaciones monetarias en este periodo',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _monetaryDonations.length,
      itemBuilder: (context, index) {
        final donation = _monetaryDonations[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${donation.amount} ${donation.currency.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(donation.paymentStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        donation.paymentStatus.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Método: ${donation.paymentService.name}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (donation.volunteer != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Donado por: ${donation.volunteer!.name} ${donation.volunteer!.surname}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (donation.assignedVictim != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Asignado a: ${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Registrado: ${_formatDate(donation.donationDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    if (donation.transactionId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.tag, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ID Transacción: ${donation.transactionId}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
    Color _getStatusColor(PaymentStatus status) {
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

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minContentWidth = math.max(950.0, constraints.maxWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minContentWidth,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Resumen de Recursos',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: FutureBuilder<double>(
                            future: _totalMoneyFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildInfoCard('Total recaudado', 'Cargando...');
                              } else if (snapshot.hasError) {
                                return _buildInfoCard('Total recaudado', 'Error al cargar');
                              } else {
                                double value = snapshot.data ?? 0.0;
                                return _buildInfoCard('Total recaudado', '€${value.toStringAsFixed(2)}');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: FutureBuilder<int>(
                            future: _totalResourcesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildInfoCard('Recursos donados', 'Cargando...');
                              } else if (snapshot.hasError) {
                                return _buildInfoCard('Recursos donados', 'Error al cargar');
                              } else {
                                return _buildInfoCard('Recursos donados', '${snapshot.data ?? 0}');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: FutureBuilder<int>(
                            future: _totalDonorsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildInfoCard('Donantes activos', 'Cargando...');
                              } else if (snapshot.hasError) {
                                return _buildInfoCard('Donantes activos', 'Error al cargar');
                              } else {
                                return _buildInfoCard('Donantes activos', '${snapshot.data ?? 0}');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 25.0),
                      child: Text(
                        'Distribución de recursos por tipo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    constraints: BoxConstraints(minWidth: math.max(700, constraints.maxWidth * 0.8)),
                    height: 400,
                    child: FutureBuilder<Map<String, int>>(
                      future: _donationsByTypeFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los datos: ${snapshot.error}',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay datos disponibles para este periodo'),
                          );
                        }

                        final data = snapshot.data!.entries
                            .map((entry) => {
                                  'type': entry.key,
                                  'count': entry.value,
                                })
                            .toList();

                        return CustomPieChart(
                          data: data,
                          legendScrollController: _pieChartScrollController,
                          threshold: 10.0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Divider
                  const Divider(
                    height: 40,
                    thickness: 2,
                    indent: 40,
                    endIndent: 40,
                    color: Colors.grey,
                  ),
                  
                  // Weekly Donations Bar Chart
                  _buildWeeklyDonationsChart(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          Text(
            value, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationHistoryContent() {
    String dateRangeText = '';
    if (widget.fechaInicio != null && widget.fechaFin != null) {
      dateRangeText = 'Periodo: ${widget.fechaInicio!.day}/${widget.fechaInicio!.month}/${widget.fechaInicio!.year} - '
                     '${widget.fechaFin!.day}/${widget.fechaFin!.month}/${widget.fechaFin!.year}';
    }    
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial de Donaciones',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (dateRangeText.isNotEmpty)
                Text(
                  dateRangeText,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // unassigned physical donations
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _unassignedExpanded = !_unassignedExpanded;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.inventory, color: Colors.red),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Donaciones Físicas Sin Asignar',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getUnassignedDonations().length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _unassignedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_unassignedExpanded)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildUnassignedDonationsSection(),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // assigned physical donations
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _assignedExpanded = !_assignedExpanded;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.green.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_turned_in, color: Colors.green),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Donaciones Físicas Asignadas',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getAssignedDonations().length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _assignedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_assignedExpanded)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildAssignedDonationsSection(),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // monetary donations
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blue.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _monetaryExpanded = !_monetaryExpanded;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.euro, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Donaciones Monetarias',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_monetaryDonations.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _monetaryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_monetaryExpanded)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildMonetaryDonationsSection(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatWeekLabel(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formateando fecha: $dateString, error: $e');
      return dateString;
    }
  }

  Widget _buildWeeklyDonationsChart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 25.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Evolución semanal de donaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDonationType,
                      onChanged: _onDonationTypeChanged,
                      items: const [
                        DropdownMenuItem(
                          value: 'physical',
                          child: Row(
                            children: [
                              Icon(Icons.inventory, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Donaciones Físicas'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'monetary',
                          child: Row(
                            children: [
                              Icon(Icons.euro, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Donaciones Monetarias'),
                            ],
                          ),
                        ),
                      ],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      dropdownColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 500,
            child: FutureBuilder<Map<String, double>>(
              future: _weeklyDonationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar los datos: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay datos disponibles para este periodo'),
                  );
                }


                final data = snapshot.data!.entries
                    .map((entry) => {
                          'item1': _formatWeekLabel(entry.key),
                          'item2': entry.value,
                        })
                    .toList();

                return CustomBarChart(
                  data: data,
                  barColor: _selectedDonationType == 'physical' 
                      ? const Color(0xFF2196F3) 
                      : const Color(0xFF4CAF50),
                  tooltipColor: _selectedDonationType == 'physical' 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF4CAF50),
                  legendScrollController: _barChartScrollController,
                  padding: const EdgeInsets.fromLTRB(40.0, 0.0, 50.0, 80.0),
                  threshold: 0.0, 
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboard(),
          const Divider(
            height: 40,
            thickness: 2,
            indent: 40,
            endIndent: 40,
            color: Colors.grey,
          ),
          _buildDonationHistoryContent(),
        ],
      ),
    );
  }
}
