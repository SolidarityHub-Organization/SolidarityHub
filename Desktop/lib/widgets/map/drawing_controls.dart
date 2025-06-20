import 'package:flutter/material.dart';

class DrawingControls extends StatelessWidget {
  final Function() onToggleDrawing;
  final Function() onUndoPoint;
  final Function() onFinishDrawing;
  final bool isDrawingMode;
  final int currentPointsCount;
  final String selectedHazardLevel;
  final Function(String) onHazardLevelChanged;

  const DrawingControls({
    Key? key,
    required this.onToggleDrawing,
    required this.onUndoPoint,
    required this.onFinishDrawing,
    required this.isDrawingMode,
    required this.currentPointsCount,
    required this.selectedHazardLevel,
    required this.onHazardLevelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hazard level selector
          DropdownButton<String>(
            value: selectedHazardLevel,
            items: [
              DropdownMenuItem(value: 'low', child: Text('Bajo')),
              DropdownMenuItem(value: 'medium', child: Text('Medio')),
              DropdownMenuItem(value: 'high', child: Text('Alto')),
            ],
            onChanged: (value) {
              if (value != null) onHazardLevelChanged(value);
            },
          ),
          
          SizedBox(height: 8),
          
          // Points counter
          Text('Puntos: $currentPointsCount'),
          
          SizedBox(height: 8),
          
          // Control buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: currentPointsCount > 0 ? onUndoPoint : null,
                child: Text('Deshacer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: currentPointsCount >= 3 ? onFinishDrawing : null,
                child: Text('Finalizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}