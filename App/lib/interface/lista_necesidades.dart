import 'package:flutter/material.dart';
import '../models/necesidad.dart';
import '../services/necesidades_service.dart';
import '../models/necesidad_card.dart';

class ListaNecesidadesPage extends StatefulWidget {
  const ListaNecesidadesPage({Key? key}) : super(key: key);

  @override
  State<ListaNecesidadesPage> createState() => _ListaNecesidadesPageState();
}

class _ListaNecesidadesPageState extends State<ListaNecesidadesPage> {
  final NecesidadesService _service = NecesidadesService();
  List<Necesidad> _necesidades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNecesidades();
  }

  Future<void> _cargarNecesidades() async {
    try {
      final data = await _service.obtenerTodasLasNecesidades();
      setState(() => _necesidades = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las necesidades')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "NECESIDADES ABIERTAS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de tarjetas
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _necesidades.isEmpty
                    ? Center(child: Text("No hay necesidades disponibles."))
                    : ListView.builder(
                  itemCount: _necesidades.length,
                  itemBuilder: (context, index) {
                    return NecesidadCard(necesidad: _necesidades[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
