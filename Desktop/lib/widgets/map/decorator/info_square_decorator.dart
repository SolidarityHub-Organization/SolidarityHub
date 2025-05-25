import 'package:flutter/material.dart';
import 'package:solidarityhub/models/mapMarker.dart';
import '../factory_method_info/info_square_factory.dart';

class InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  InfoRowData({required this.icon, required this.label, required this.value, this.valueColor});
}

class CompleteStyleDecorator implements InfoSquare {
  final InfoSquare infoSquare;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData mainIcon;
  final List<InfoRowData> rows;

  CompleteStyleDecorator({
    required this.infoSquare,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
    required this.mainIcon,
    required this.rows,
  });

  factory CompleteStyleDecorator.create(
    InfoSquare infoSquare, {
    required String title,
    required Color primaryColor,
    required Color secondaryColor,
    required IconData mainIcon,
    required List<InfoRowData> rows,
  }) {
    return CompleteStyleDecorator(
      infoSquare: infoSquare,
      title: title,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      mainIcon: mainIcon,
      rows: rows,
    );
  }

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    Widget baseWidget = infoSquare.buildInfoSquare(mapMarker);
    bool hasBaseContent = baseWidget is! EmptyInfoSquare && baseWidget != null;
    Color backgroundColor = _getBackgroundColorForType(mapMarker.type);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.7), width: 2),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.7), shape: BoxShape.circle),
                    child: Icon(mainIcon, color: Colors.white, size: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(color: primaryColor.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.7), borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rows.map((row) => _buildStyledInfoRow(row)),
                  if (hasBaseContent) Divider(color: Colors.grey.withOpacity(0.3), thickness: 1, height: 32),
                  if (hasBaseContent) baseWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledInfoRow(InfoRowData row) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(row.icon, size: 16, color: primaryColor),
          SizedBox(height: 6),
          Text(
            row.label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Divider(height: 16, thickness: 1, color: primaryColor.withOpacity(0.2)),
          Text(row.value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _getBackgroundColorForType(String type) {
    String normalizedType = type.toLowerCase().trim();

    if (normalizedType.contains("affect")) {
      return Color(0xFFFEE8EB);
    } else if (normalizedType.contains("volunt")) {
      return Color(0xFFFFEDF3);
    } else if (normalizedType.contains("task") || normalizedType.contains("tarea")) {
      return Color(0xFFFFF5E6);
    } else if (normalizedType.contains("meet") || normalizedType.contains("encuentro")) {
      return Color(0xFFEDF7EE);
    } else if (normalizedType.contains("pick") || normalizedType.contains("recogida")) {
      return Color(0xFFE9F5FE);
    } else {
      return Color(0xFFFEE8EB);
    }
  }

  Widget _buildInfoRow(InfoRowData row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(row.icon, color: primaryColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 2),
                Text(row.value, style: TextStyle(fontSize: 16, color: row.valueColor ?? Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
