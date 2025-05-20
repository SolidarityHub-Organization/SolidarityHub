import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/solicitud_recursos_controller.dart';
import '../models/recurso.dart';
import '../services/services_recursos.dart';

class SolicitarRecursoPage extends StatefulWidget {

  final int id;
  SolicitarRecursoPage({required this.id});

  @override
  _SolicitarRecursoPageState createState() => _SolicitarRecursoPageState();
}

class _SolicitarRecursoPageState extends State<SolicitarRecursoPage> {
  late SolicitarRecursoController _controller;
  final RecursosService _recursosService = RecursosService();

  List<Recurso> _recursos = [];
  Recurso? recursoSeleccionado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = SolicitarRecursoController(id: widget.id);
    _fetchRecursos();
  }

  Future<void> _fetchRecursos() async {
    try {
      final recursos = await _recursosService.obtenerRecursos();
      setState(() {
        _recursos = recursos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los recursos')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "SOLICITAR RECURSO",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),

            // Contenedor principal
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Seleccione un recurso:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<Recurso>(
                        value: recursoSeleccionado,
                        items: _recursos.map<DropdownMenuItem<Recurso>>((Recurso recurso) {
                          return DropdownMenuItem<Recurso>(
                            value: recurso,
                            child: Text(recurso.name),
                          );
                        }).toList(),
                        onChanged: (Recurso? nuevoValor) {
                          setState(() {
                            recursoSeleccionado = nuevoValor;
                            _controller.recursoSeleccionado = nuevoValor;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Tipo de recurso',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Seleccione la cantidad:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      TextField(
                        controller: _controller.cantidadController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: "Cantidad",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _controller.descripcionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Descripción (opcional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _controller.registrarSolicitud(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 0),
                        ),
                        child: Text(
                          "Registrar Solicitud",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
