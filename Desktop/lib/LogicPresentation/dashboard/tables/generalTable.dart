import 'package:flutter/material.dart';
import '../../../services/generalServices.dart';

class GeneralTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const GeneralTab({Key? key, required this.fechaFin, required this.fechaInicio}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GeneralTabState(); // Implementación corregida
  }
}

class _GeneralTabState extends State<GeneralTab> {
  final GeneralService _generalService = GeneralService('http://localhost:5170');

  DateTime _adjustEndDate(DateTime? date) {
    if (date == null) return DateTime.now();
    // Ajustar la fecha fin para incluir todo el día (23:59:59.999)
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  DateTime _adjustStartDate(DateTime? date) {
    if (date == null) return DateTime(2000, 1, 1);
    // Ajustar la fecha inicio para comenzar al principio del día (00:00:00.000)
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  late Future<int> _victimCountFuture;
  late Future<int> _volunteerCountFuture;

  @override
  void initState() {
    super.initState();
    _victimCountFuture = _generalService.fetchVictimCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
    _volunteerCountFuture = _generalService.fetchVolunteerCount(
      _adjustStartDate(widget.fechaInicio),
      _adjustEndDate(widget.fechaFin),
    );
  }

  @override
  void didUpdateWidget(covariant GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fechaInicio != widget.fechaInicio || oldWidget.fechaFin != widget.fechaFin) {
      setState(() {
        _victimCountFuture = _generalService.fetchVictimCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
        _volunteerCountFuture = _generalService.fetchVolunteerCount(
          _adjustStartDate(widget.fechaInicio),
          _adjustEndDate(widget.fechaFin),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50), // Espacio superior
          const Text(
            'Resumen General',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(height: 20), // Espacio debajo del texto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FutureBuilder<int>(
                future: _victimCountFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInfoCard('Personas Afectadas', 'Cargando...');
                  } else if (snapshot.hasError) {
                    // Mostrar más detalles sobre el error

                    return _buildInfoCard(
                      'Personas Afectadas',
                      'Error: ${snapshot.error.toString().substring(0, snapshot.error.toString().length > 30 ? 30 : snapshot.error.toString().length)}...',
                    );
                  } else if (!snapshot.hasData) {
                    // Verificamos si no hay datos aunque no haya error
                    return _buildInfoCard('Personas Afectadas', 'Sin datos');
                  } else {
                    return _buildInfoCard('Personas Afectadas', snapshot.data.toString());
                  }
                },
              ),
              FutureBuilder<int>(
                future: _volunteerCountFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInfoCard('Voluntarios Totales', 'Cargando...');
                  } else if (snapshot.hasError) {
                    return _buildInfoCard('Voluntarios Totales', 'Error');
                  } else {
                    return _buildInfoCard('Voluntarios Totales', snapshot.data.toString());
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20), // Espacio entre filas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard('Donaciones Recibidas', '0'), // Valor predeterminado
              _buildInfoCard('Eventos Realizados', '0'), // Título y valor corregidos
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: 500, // Ancho del recuadro
      height: 200, // Alto del recuadro
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4), // Sombra hacia abajo
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 12.0),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}
