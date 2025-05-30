import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:solidarityhub/screens/login_admin.dart';
import 'package:solidarityhub/screens/dashboard/dashboard.dart';
import 'package:solidarityhub/screens/donations/donations.dart';
import 'package:solidarityhub/screens/tasks_screen.dart';
import 'package:solidarityhub/services/database_services.dart';
import 'package:solidarityhub/screens/map.dart';
import 'package:solidarityhub/utils/logger.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true),
      home: const MinSizeContainer(child: MyHomePage(title: 'Solidarity Hub')),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      locale: const Locale('es', 'ES'),
    );
  }
}

class MinSizeContainer extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;

  const MinSizeContainer({Key? key, required this.child, this.minWidth = 281.0, this.minHeight = 175.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
              width: constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth,
              height: constraints.maxHeight > minHeight ? constraints.maxHeight : minHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class MenuOption {
  final int index;
  final IconData icon;
  final String title;
  final Widget Function()? builder;
  final void Function(BuildContext)? action;

  const MenuOption({required this.index, required this.icon, required this.title, this.builder, this.action});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _currentContent = const Dashboard();
  int _selectedIndex = 0;
  bool _isExpanded = true;
  final ScrollController _sidebarScrollController = ScrollController();

  final List<MenuOption> _menuOptions = [
    MenuOption(index: 0, icon: Icons.dashboard, title: 'Dashboard', builder: () => const Dashboard()),
    MenuOption(index: 1, icon: Icons.login, title: 'Iniciar sesión Admin', builder: () => const Loginadmin()),
    MenuOption(index: 2, icon: Icons.map, title: 'Mapa', builder: () => const MapScreen()),
    MenuOption(index: 3, icon: Icons.task, title: 'Crear tareas', builder: () => const TasksScreen()),
    MenuOption(
      index: 4,
      icon: Icons.book,
      title: 'Donaciones',
      builder: () => const DonationsPage(baseUrl: 'http://localhost:5170'),
    ),
    MenuOption(
      index: -2,
      icon: Icons.add_box,
      title: 'Poblar Base de Datos',
      action: (ctx) {
        Logger.runAsync(DatabaseServices.populateDatabase);
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Poblando base de datos...'), backgroundColor: Colors.green));
      },
    ),
    MenuOption(
      index: -4,
      icon: Icons.add_box,
      title: 'Superpoblar Base de Datos',
      action: (ctx) {
        Logger.runAsync(DatabaseServices.superPopulateDatabase);
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Superpoblando base de datos...'), backgroundColor: Colors.green));
      },
    ),
    MenuOption(
      index: -3,
      icon: Icons.delete,
      title: 'Limpiar Base de Datos',
      action: (ctx) {
        Logger.runAsync(DatabaseServices.clearDatabase);
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('Limpiando base de datos...'), backgroundColor: Colors.red));
      },
    ),
  ];

  void _onMenuOptionTap(MenuOption opt) {
    setState(() {
      _selectedIndex = opt.index;
      if (opt.builder != null) {
        _currentContent = opt.builder!();
      }
    });
    opt.action?.call(context);
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isExpanded ? 280 : 70,
            color: Colors.white,
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
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _sidebarScrollController,
                      child: ListView(
                        controller: _sidebarScrollController,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        children:
                            _menuOptions
                                .expand(
                                  (opt) => [
                                    _buildMenuItem(opt),
                                    if (opt.index == 4)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Divider(height: 1),
                                      ),
                                  ],
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.red.withOpacity(0.1),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child:
                            _isExpanded
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(Icons.chevron_left, color: Colors.red),
                                    const SizedBox(width: 12),
                                    Flexible(
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

  Widget _buildMenuItem(MenuOption opt) {
    final bool isSelected = opt.index == _selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => _onMenuOptionTap(opt),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(opt.icon, color: isSelected ? Colors.red : Colors.red.withOpacity(0.7), size: 22),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              opt.title,
                              style: TextStyle(
                                color: isSelected ? Colors.red : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      )
                      : Center(
                        child: Icon(opt.icon, color: isSelected ? Colors.red : Colors.red.withOpacity(0.7), size: 24),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
