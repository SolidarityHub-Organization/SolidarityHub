import 'package:flutter/material.dart';

// Leyenda para el mapa de calor
class HeatMapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLegendCard(
      title: 'Densidad',
      items: [
        LegendItem(color: Colors.red.withOpacity(0.8), label: 'Alta'),
        LegendItem(color: Colors.orange.withOpacity(0.8), label: 'Media'),
        LegendItem(color: Colors.yellow.withOpacity(0.8), label: 'Baja'),
        LegendItem(color: Colors.grey.withOpacity(0.8), label: 'Sin nivel definido'),
      ],
    );
  }
}

// Leyenda para los niveles de urgencia
class UrgencyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLegendCard(
      title: 'Niveles de Urgencia',
      items: [
        LegendItem(color: Colors.green, label: 'Bajo'),
        LegendItem(color: Colors.orange, label: 'Medio'),
        LegendItem(color: Colors.red, label: 'Alto'),
        LegendItem(color: Colors.red.shade900, label: 'Crítico'),
        LegendItem(color: Colors.grey, label: 'Desconocido'),
      ],
    );
  }
}

// Leyenda para los estados de tareas
class TaskLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLegendCard(
      title: 'Estados de Tareas',
      items: [
        LegendItem(color: Colors.green, label: 'Completado'),
        LegendItem(color: Colors.orange, label: 'Asignado'),
        LegendItem(color: Colors.blue, label: 'Pendiente'),
        LegendItem(color: Colors.red, label: 'Cancelado'),
      ],
    );
  }
}

// Clase para representar un elemento de la leyenda
class LegendItem {
  final Color color;
  final String label;

  LegendItem({required this.color, required this.label});
}

// Función para construir un widget de leyenda con título y elementos
Widget _buildLegendCard({required String title, required List<LegendItem> items}) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                SizedBox(width: 4),
                Text(item.label, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
