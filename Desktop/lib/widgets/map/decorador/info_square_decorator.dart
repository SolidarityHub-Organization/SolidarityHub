import 'package:flutter/material.dart';
import '../../../models/mapMarker.dart';
import '../factory_method_info/info_square_factory.dart';

/// Decorador base para InfoSquare
abstract class InfoSquareDecorator implements InfoSquare {
  final InfoSquare _inner;

  InfoSquareDecorator(this._inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return _inner.buildInfoSquare(mapMarker);
  }
}

/// Clase para representar datos de una fila de información
class InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  InfoRowData({required this.icon, required this.label, required this.value, this.valueColor});
}

/// Decorador que personaliza la apariencia visual del InfoSquare
class CustomInfoSquareDecorator extends InfoSquareDecorator {
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  CustomInfoSquareDecorator(
    InfoSquare inner, {
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.margin = const EdgeInsets.all(8),
    this.borderRadius = 8,
    this.backgroundColor,
    this.boxShadow,
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor,
        boxShadow: boxShadow,
      ),
      child: super.buildInfoSquare(mapMarker),
    );
  }
}

/// Decorador que añade un icono al InfoSquare
class IconInfoSquareDecorator extends InfoSquareDecorator {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  IconInfoSquareDecorator(
    InfoSquare inner, {
    required this.icon,
    this.iconColor = Colors.black,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Column(
      children: [
        Padding(padding: padding, child: Icon(icon, color: iconColor, size: iconSize)),
        super.buildInfoSquare(mapMarker),
      ],
    );
  }
}

/// Decorador que personaliza el estilo de texto del InfoSquare
class ContentInfoSquareDecorator extends InfoSquareDecorator {
  final TextStyle titleStyle;
  final TextStyle contentStyle;
  final EdgeInsetsGeometry contentPadding;

  ContentInfoSquareDecorator(
    InfoSquare inner, {
    this.titleStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    this.contentStyle = const TextStyle(fontSize: 14),
    this.contentPadding = const EdgeInsets.all(8.0),
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    final baseWidget = super.buildInfoSquare(mapMarker);

    return Builder(
      builder: (context) {
        if (baseWidget is Container && baseWidget.child is Column) {
          Column column = baseWidget.child as Column;
          List<Widget> children = [];

          for (var widget in column.children) {
            if (widget is Text) {
              // Aplicar estilo al título o contenido
              if (children.isEmpty) {
                children.add(Text(widget.data ?? '', style: titleStyle));
              } else {
                children.add(Padding(padding: contentPadding, child: Text(widget.data ?? '', style: contentStyle)));
              }
            } else {
              children.add(widget);
            }
          }

          return Container(
            decoration: (baseWidget).decoration,
            margin: (baseWidget).margin,
            padding: (baseWidget).padding,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          );
        }

        return baseWidget;
      },
    );
  }
}

/// Decorador que configura el diseño base con encabezado, separadores y pie
class BaseLayoutDecorator extends InfoSquareDecorator {
  final String title;
  final Color titleColor;
  final Color dividerColor;
  final Color footerColor;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  BaseLayoutDecorator(
    InfoSquare inner, {
    required this.title,
    required this.titleColor,
    required this.dividerColor,
    required this.footerColor,
    this.icon,
    this.iconColor,
    this.iconSize = 36.0,
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      // Envolvemos todo en un SingleChildScrollView para permitir scroll cuando sea necesario
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 40),
            Divider(color: dividerColor, thickness: 2.0, height: 32),
            SizedBox(height: 40),
            super.buildInfoSquare(mapMarker),
            SizedBox(height: 50),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: titleColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconColor ?? titleColor, size: iconSize),
          ),
          SizedBox(width: 16),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: titleColor),
            // Agregamos ajuste de texto para evitar desbordamientos
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: dividerColor.withOpacity(0.7), thickness: 1.0),
        SizedBox(height: 20),
        Center(
          child: Text(
            'Información actualizada',
            style: TextStyle(color: footerColor, fontStyle: FontStyle.italic, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// Decorador para crear filas de información con el mismo estilo
class InfoRowDecorator extends InfoSquareDecorator {
  final List<InfoRowData> rows;
  final Color borderColor;
  final Color iconColor;
  final Color labelColor;

  InfoRowDecorator(
    InfoSquare inner, {
    required this.rows,
    required this.borderColor,
    required this.iconColor,
    required this.labelColor,
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    List<Widget> content = [];

    // Agregar todas las filas de información
    for (int i = 0; i < rows.length; i++) {
      content.add(_buildInfoRow(rows[i]));

      // Agregar espacio entre las filas (excepto la última)
      if (i < rows.length - 1) {
        content.add(SizedBox(height: 30));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);
  }

  Widget _buildInfoRow(InfoRowData data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      // Aseguramos que todo el contenedor se ajuste
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Corregimos el uso del widget Flexible
          Row(
            children: [
              Icon(data.icon, size: 22, color: iconColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: labelColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              data.value,
              style: TextStyle(
                fontSize: 18,
                color: data.valueColor ?? Colors.black87,
                fontWeight: data.valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
              // Ajustamos el texto para evitar overflows
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorador que combina varios estilos en uno solo
class CompleteStyleDecorator extends InfoSquareDecorator {
  final Color primaryColor;
  final Color secondaryColor;
  final IconData mainIcon;

  CompleteStyleDecorator(
    InfoSquare inner, {
    required this.primaryColor,
    required this.secondaryColor,
    required this.mainIcon,
    required String title,
  }) : super(inner);

  /// Método de fábrica para crear un decorador completo
  factory CompleteStyleDecorator.create(
    InfoSquare inner, {
    required String title,
    required Color primaryColor,
    required Color secondaryColor,
    required IconData mainIcon,
    required List<InfoRowData> rows,
  }) {
    // Construir la cadena de decoradores de adentro hacia afuera
    return CompleteStyleDecorator(
      CustomInfoSquareDecorator(
        BaseLayoutDecorator(
          InfoRowDecorator(
            inner,
            rows: rows,
            borderColor: secondaryColor.withOpacity(0.5),
            iconColor: primaryColor,
            labelColor: primaryColor,
          ),
          title: title,
          titleColor: primaryColor,
          dividerColor: secondaryColor,
          footerColor: primaryColor,
          icon: mainIcon,
          iconColor: primaryColor,
        ),
        borderWidth: 0.5,
        borderColor: primaryColor.withOpacity(0.3),
        borderRadius: 16.0,
        backgroundColor: secondaryColor.withOpacity(0.1),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8.0, offset: Offset(0, 3))],
        // Aseguramos que el margen no sea excesivo en pantallas pequeñas
        margin: const EdgeInsets.all(4),
      ),
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      mainIcon: mainIcon,
      title: title,
    );
  }

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return super.buildInfoSquare(mapMarker);
  }
}

/// Decorador simple para agregar un borde
class BorderInfoSquareDecorator extends InfoSquareDecorator {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  BorderInfoSquareDecorator(
    InfoSquare inner, {
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.borderRadius = 8,
  }) : super(inner);

  @override
  Widget buildInfoSquare(MapMarker mapMarker) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: super.buildInfoSquare(mapMarker),
    );
  }
}
