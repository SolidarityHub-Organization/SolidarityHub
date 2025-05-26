import 'package:flutter/material.dart';
import '../models/TipoSolicitud.dart';
import '../services/tipo_solicitud_service.dart';
import '../models/TipoSolicitudCard.dart';
import '../controllers/tipo_solicitud_controller.dart';

class TiposSolicitudesPage extends StatefulWidget {
  final int id;
  const TiposSolicitudesPage({required this.id});

  @override
  State<TiposSolicitudesPage> createState() => _TiposSolicitudesPageState();
}

class _TiposSolicitudesPageState extends State<TiposSolicitudesPage> {
  final TipoSolicitudService _service = TipoSolicitudService();
  final TipoSolicitudController _controller = TipoSolicitudController();

  List<TipoSolicitud> _tipos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  Future<void> _cargarTipos() async {
    try {
      final data = await _service.obtenerTiposSolicitud(widget.id);

      data.sort((a, b) {
        final estadoA = a.status.trim().isEmpty ? 'pending' : a.status.toLowerCase();
        final estadoB = b.status.trim().isEmpty ? 'pending' : b.status.toLowerCase();

        if (estadoA == 'pending' && estadoB != 'pending') return -1;
        if (estadoA != 'pending' && estadoB == 'pending') return 1;
        return 0;
      });

      setState(() {
        _tipos = data;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los tipos de solicitud')),
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
                    "SOLICITUDES REALIZADAS",
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
                    : _tipos.isEmpty
                    ? Center(child: Text("No hay solicitudes disponibles."))
                    : ListView.builder(
                  itemCount: _tipos.length,
                  itemBuilder: (context, index) {
                    final solicitud = _tipos[index];

                    final bool esFinalizada = solicitud.status.toLowerCase() == "completed";
                    final bool esCancelada = solicitud.status.toLowerCase() == "cancelled";
                    final bool desactivarBotones = esFinalizada || esCancelada;

                    return TipoSolicitudCard(
                      tipo: solicitud,
                      onCancelar: desactivarBotones
                          ? null
                          : () {
                        _controller.actualizarEstado(
                          context: context,
                          solicitudId: solicitud.id,
                          nuevoEstado: "Cancelled",
                          onSuccess: _cargarTipos,
                        );
                      },
                      onCompletar: desactivarBotones
                          ? null
                          : () {
                        _controller.actualizarEstado(
                          context: context,
                          solicitudId: solicitud.id,
                          nuevoEstado: "Completed",
                          onSuccess: _cargarTipos,
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