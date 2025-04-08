import 'package:flutter/material.dart';
import 'tables/generalTable.dart';
import 'tables/victimTable.dart';
import 'tables/resourceTable.dart';
import 'tables/volunteerTable.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7dias';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: const [
                            Tab(text: 'General'),
                            Tab(text: 'Afectados'),
                            Tab(text: 'Recursos'),
                            Tab(text: 'Voluntarios'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: const [
                              DropdownMenuItem(
                                value: '24h',
                                child: Text('Últimas 24 horas'),
                              ),
                              DropdownMenuItem(
                                value: '7dias',
                                child: Text('Últimos 7 días'),
                              ),
                              DropdownMenuItem(
                                value: '30dias',
                                child: Text('Últimos 30 días'),
                              ),
                              DropdownMenuItem(
                                value: 'total',
                                child: Text('Total'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedPeriod = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GeneralTab(selectedPeriod: _selectedPeriod),
                VictimsTab(selectedPeriod: _selectedPeriod),
                const RecursosTab(),
                VolunteerTab(selectedPeriod: _selectedPeriod),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
