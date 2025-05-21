import 'package:flutter/material.dart';
import '../models/solicitud.dart';
import '../controllers/solicitudes_controller.dart';
import '../models/solicitud_card.dart';

class SolicitudesPage extends StatefulWidget {
  final int id;
  const SolicitudesPage({required this.id});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  final SolicitudesController _controller = SolicitudesController();

  List<Solicitud> _solicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _isLoading = true);
    try {
      final datos = await _controller.cargarSolicitudes(widget.id);
      setState(() {
        _solicitudes = datos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar solicitudes')),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "MIS SOLICITUDES",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de solicitudes
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
                    : _solicitudes.isEmpty
                    ? Center(child: Text("No hay solicitudes."))
                    : ListView.separated(
                  itemCount: _solicitudes.length,
                  separatorBuilder: (_, __) => Divider(height: 24),
                  itemBuilder: (context, index) {
                    final solicitud = _solicitudes[index];
                    return SolicitudCard(
                      solicitud: solicitud,
                      onCancelar: () {
                        _controller.cancelarSolicitud(
                          context: context,
                          solicitudId: solicitud.id,
                          onSuccess: _cargarSolicitudes,
                        );
                      },
                      onCompletar: () {
                        _controller.completarSolicitud(
                          context: context,
                          solicitudId: solicitud.id,
                          onSuccess: _cargarSolicitudes,
                        );
                      },
                    );
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
