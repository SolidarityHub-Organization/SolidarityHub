import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../LogicBusiness/services/victimServices.dart'; // Importa el servicio

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];
  final VictimService _userServices = VictimService(
    'http://localhost:5170',
  ); // Corrige el símbolo '>' en la URL

  @override
  void initState() {
    super.initState();
    _fetchVictimLocations();
  }

  Future<void> _fetchVictimLocations() async {
    try {
      final locations = await _userServices.fetchLocations();
      print(locations);
      setState(() {
        _markers =
            locations.map((location) {
              return Marker(
                point: LatLng(location['latitude'], location['longitude']),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    // Muestra un diálogo con los detalles de la víctima
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Detalles de la víctima'),
                            content: Text(
                              'ID: ${location['id']}\nNombre: ${location['name']}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cerrar'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
                ),
              );
            }).toList();
      });
    } catch (e) {
      // Mejora la gestión de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las ubicaciones: $e')),
      );
      print('Error al obtener las ubicaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: "Se desarrollará en el Sprint 2",
                  child: ElevatedButton(
                    onPressed: () {}, // Botón habilitado (sin funcionalidad)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Botón 1",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Tooltip(
                  message: "Se desarrollará en el Sprint 2",
                  child: ElevatedButton(
                    onPressed: () {}, // Botón habilitado (sin funcionalidad)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Botón 2",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(39.47391, -0.37966),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: ['a', 'b', 'c', 'd'],
                      ),
                      MarkerLayer(markers: _markers), // Muestra los marcadores
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
