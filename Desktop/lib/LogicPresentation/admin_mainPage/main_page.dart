import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  final List<String> menuItems = [
    'Inicio',
    'Tareas',
    'Voluntarios',
    'Afectados',
    'Mapa'
  ];

  int activeTasksCount = 0;
  int availableVolunteersCount = 0;
  int completedTasksCount = 0;
  int affectedZonesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchActiveTasks();
    _fetchAvailableVolunteers();
    _fetchCompletedTasks();
    _fetchAffectedZones();
  }

  Future<void> _fetchActiveTasks() async {
    final url = Uri.parse("http://localhost:5170/api/v1/tasks?state=active");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> tasks = json.decode(response.body);
        setState(() {
          activeTasksCount = tasks.length;
        });
      } else {
        throw Exception("Failed to fetch active tasks: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching active tasks: $error");
    }
  }

  Future<void> _fetchAvailableVolunteers() async {
    final url = Uri.parse("http://localhost:5170/api/v1/volunteers?state=available");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> volunteers = json.decode(response.body);
        setState(() {
          availableVolunteersCount = volunteers.length;
        });
      } else {
        throw Exception("Failed to fetch available volunteers: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching available volunteers: $error");
    }
  }

  Future<void> _fetchCompletedTasks() async {
    final url = Uri.parse("http://localhost:5170/api/v1/tasks?state=completed");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> tasks = json.decode(response.body);
        setState(() {
          completedTasksCount = tasks.length;
        });
      } else {
        throw Exception("Failed to fetch completed tasks: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching completed tasks: $error");
    }
  }

  Future<void> _fetchAffectedZones() async {
    final url = Uri.parse("http://localhost:5170/api/v1/zones?state=affected");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> zones = json.decode(response.body);
        setState(() {
          affectedZonesCount = zones.length;
        });
      } else {
        throw Exception("Failed to fetch affected zones: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching affected zones: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: const Text(
                  'Administración',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: menuItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )).toList(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardCard(
                'Tareas Activas',
                'Tareas en curso',
                '$activeTasksCount',
                'Ver todas las tareas',
                () {
                  // Acción para "Ver todas las tareas"
                },
              ),
              _buildDashboardCard(
                'Voluntarios Disponibles',
                'Voluntarios sin asignar',
                '$availableVolunteersCount',
                'Gestionar voluntarios',
                () {
                  // Acción para "Gestionar voluntarios"
                },
              ),
              _buildDashboardCard(
                'Tareas Completadas',
                'Tareas finalizadas',
                '$completedTasksCount',
                'Ver informes',
                () {
                  // Acción para "Ver informes"
                },
              ),
              _buildDashboardCard(
                'Zonas Afectadas',
                'Zonas en alerta',
                '$affectedZonesCount',
                'Ver zonas afectadas',
                () {
                  // Acción para "Ver zonas afectadas"
                },
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, String value, String buttonText, VoidCallback onPressed) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
