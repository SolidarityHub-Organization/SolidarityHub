import 'package:flutter/material.dart';
import 'package:solidarityhub/models/imap_component.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import 'package:solidarityhub/models/mapMarkerCluster.dart';
import 'package:solidarityhub/widgets/map/factory_method_info/info_square_factory.dart';

class MapInfoPanel extends StatelessWidget {
  final IMapComponent component;
  final VoidCallback onClose;

  const MapInfoPanel({Key? key, required this.component, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(-2, 0))],
      ),
      child: Column(
        children: [
          // Cabecera completamente rediseñada
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón de cierre alineado a la derecha
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: onClose,
                    child: Container(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: Colors.red, size: 20)),
                  ),
                ),
                // Texto del título en su propia línea
                Container(
                  width: double.infinity,
                  child: Text(
                    component is MapMarkerCluster ? 'Grupo de marcadores' : 'Detalles',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: component is MapMarkerCluster ? _buildClusterInfo(component as MapMarkerCluster) : _buildMarkerInfo(component as MapMarker),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerInfo(MapMarker marker) {
    // Usamos la fábrica de cuadros de información para crear el tipo correcto
    final infoSquare = InfoSquareFactory.createInfoSquare(marker.type);
    return infoSquare.buildInfoSquare(marker);
  }

  Widget _buildClusterInfo(MapMarkerCluster cluster) {
    // Get all leaf markers recursively
    List<MapMarker> allLeafMarkers = _getAllLeafMarkers(cluster);
    int totalCount = allLeafMarkers.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade400, Colors.redAccent.shade700],
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                  child: Icon(Icons.group, color: Colors.white, size: 24),
                ),
                SizedBox(height: 12),
                Text(
                  cluster.id == 'main-cluster' ? "Todos los marcadores" : "Grupo de marcadores",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  "$totalCount elementos en esta área",
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_list_bulleted, size: 18, color: Colors.red.shade800),
                    SizedBox(height: 4),
                    Text(
                      "Elementos en este grupo:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red.shade800),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                ...allLeafMarkers.map((item) => _buildClusterItem(item)),

                if (allLeafMarkers.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: Text(
                        "Haz zoom para ver elementos individuales",
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nuevo método para construir elementos de cluster sin ListTile
  Widget _buildClusterItem(IMapComponent item) {
    // Función para convertir el tipo a un texto más amigable en español
    String getTipoTexto(String type) {
      switch (type.toLowerCase()) {
        case 'victim':
          return 'Afectado';
        case 'volunteer':
          return 'Voluntario';
        case 'task':
          return 'Tarea';
        case 'meeting_point':
          return 'Punto de encuentro';
        case 'pickup_point':
          return 'Punto de recogida';
        default:
          return 'Desconocido';
      }
    }

    // Función para obtener el color según el tipo
    Color getTipoColor(String type) {
      switch (type.toLowerCase()) {
        case 'victim':
          return Colors.red;
        case 'volunteer':
          return Color.fromARGB(255, 255, 79, 135);
        case 'task':
          return Colors.orange;
        case 'meeting_point':
          return Colors.green;
        case 'pickup_point':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Añadir etiqueta de tipo con color representativo
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: getTipoColor(item.type).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: getTipoColor(item.type).withOpacity(0.5)),
            ),
            child: Text(
              getTipoTexto(item.type),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: getTipoColor(item.type)),
            ),
          ),
          SizedBox(height: 6), // Nombre del elemento
          Text(
            item.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }


  List<MapMarker> _getAllLeafMarkers(IMapComponent component) {
    List<MapMarker> result = [];
    
    if (component is MapMarker) {
      result.add(component);
    } else if (component is MapMarkerCluster) {
      List<IMapComponent> children = component.getChildren();
      for (var child in children) {
        result.addAll(_getAllLeafMarkers(child));
      }
    }
    
    return result;
  }
}
