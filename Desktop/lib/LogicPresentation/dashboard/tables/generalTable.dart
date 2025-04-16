import 'package:flutter/material.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50), // Espacio superior
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 20), // Espacio debajo del texto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard('Personas Afectadas', '1200'),
              _buildInfoCard('Voluntarios Totales', '450'),
            ],
          ),
          const SizedBox(height: 20), // Espacio entre filas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard('Donaciones Recibidas', ''),
              _buildInfoCard('', ''),
            ],
          ),
        ],
      ),
    );
  }
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
