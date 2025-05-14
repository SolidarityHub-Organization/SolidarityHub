import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:solidarityhub/screens/login_admin.dart';
import 'package:solidarityhub/screens/dashboard/dashboard.dart';
import 'package:solidarityhub/screens/donations/donations.dart';
import 'package:solidarityhub/screens/tasks_screen.dart';
import 'package:solidarityhub/services/database_services.dart';
import 'package:solidarityhub/screens/map.dart';
import 'package:solidarityhub/utils/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true),
      home: const MyHomePage(title: 'Solidarity Hub'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'), // mantener inglés como fallback
      ],
      locale: const Locale('es', 'ES'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Inicializamos con Dashboard en lugar de contenido vacío
  Widget _currentContent = const Dashboard();
  int _selectedIndex = 0; // 0 indica Dashboard (seleccionado por defecto)
  bool _isExpanded = true;

  void _onMenuItemSelected(int index, Widget content) {
    setState(() {
      _selectedIndex = index;
      _currentContent = content;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barra lateral con ancho dinámico
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isExpanded ? 280 : 70,
            color: Colors.white,
            // Añadimos clipBehavior para recortar cualquier contenido desbordado durante la animación
            clipBehavior: Clip.hardEdge,

            child: SafeArea(
              child: Column(
                children: [
                  ClipRect(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 120,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
                      ),
                      padding: EdgeInsets.all(_isExpanded ? 16.0 : 8.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _isExpanded
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Solidarity Hub',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    'Plataforma de ayuda humanitaria',
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              )
                              : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.people_alt, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'SH',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                        },
                      ),
                    ),
                  ),

                  // Botones del menú (scrollable)
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true, // Siempre mostrar la barra de desplazamiento
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        children: [
                          _buildMenuItem(
                            index: 0,
                            icon: Icons.dashboard,
                            title: 'Dashboard',
                            onTap: () => _onMenuItemSelected(0, const Dashboard()),
                          ),
                          _buildMenuItem(
                            index: 1,
                            icon: Icons.login,
                            title: 'Iniciar sesión Admin',
                            onTap: () => _onMenuItemSelected(1, const Loginadmin()),
                          ),
                          _buildMenuItem(
                            index: 2,
                            icon: Icons.map,
                            title: 'Mapa',
                            onTap: () => _onMenuItemSelected(2, const MapScreen()),
                          ),
                          _buildMenuItem(
                            index: 3,
                            icon: Icons.task,
                            title: 'Crear tareas',
                            onTap: () => _onMenuItemSelected(3, const TasksScreen()),
                          ),
                          _buildMenuItem(
                            index: 4,
                            icon: Icons.book,
                            title: 'Donaciones',
                            onTap: () => _onMenuItemSelected(4, const DonationsPage(baseUrl: 'http://localhost:5170')),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _buildMenuItem(
                            index: -2,
                            icon: Icons.add_box,
                            title: 'Poblar Base de Datos',
                            onTap: () {
                              Logger.runAsync(DatabaseServices.populateDatabase);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Poblando base de datos...'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            index: -3,
                            icon: Icons.delete,
                            title: 'Limpiar Base de Datos',
                            onTap: () {
                              Logger.runAsync(DatabaseServices.clearDatabase);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Limpiando base de datos...'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón para expandir/colapsar la barra lateral (no scrollable)
                  Material(
                    color: Colors.red.withOpacity(0.1),
                    child: InkWell(
                      onTap: _toggleSidebar,
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child:
                            _isExpanded
                                ? Row(
                                  mainAxisSize: MainAxisSize.min, // para evitar desbordamiento
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(Icons.chevron_left, color: Colors.red),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      // Hace que el texto se ajuste al espacio disponible
                                      child: Text(
                                        'Colapsar menú',
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                                : Icon(Icons.chevron_right, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(width: 1, color: Colors.grey.shade300),

          Expanded(child: _currentContent),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final bool isSelected = index == _selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),

        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8.0 : 0, vertical: 12.0),
              child:
                  _isExpanded
                      ? Row(
                        mainAxisSize: MainAxisSize.min, //para evitar desbordamiento
                        children: [
                          Icon(icon, color: isSelected ? Colors.red : Colors.red.withOpacity(0.7), size: 22),
                          const SizedBox(width: 12),
                          Flexible(
                            // Hace que el texto se ajuste al espacio disponible
                            child: Text(
                              title,
                              style: TextStyle(
                                color: isSelected ? Colors.red : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          // Añadimos un pequeño espacio al final para evitar que toque el borde
                          const SizedBox(width: 2),
                        ],
                      )
                      : Center(
                        child: Icon(icon, color: isSelected ? Colors.red : Colors.red.withOpacity(0.7), size: 24),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
