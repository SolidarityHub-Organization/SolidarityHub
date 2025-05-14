import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class CustomBarChart extends StatelessWidget {
  final List<Map<String, dynamic>>? data;
  final Color barColor;
  final Color tooltipColor;
  final EdgeInsetsGeometry padding;

  final double rotation = 45.0; // in degrees


  const CustomBarChart({
    super.key,
    this.data,
    this.barColor = const Color(0xFFF44336),
    this.tooltipColor = const Color(0xFFF44336),
    this.padding = const EdgeInsets.fromLTRB(40.0, 0.0, 50.0, 50.0),
  });

  double _calculateMaxTitleWidth(List<Map<String, dynamic>> data) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );

    double maxWidth = 0;
    for (var item in data) {
      textPainter.text = TextSpan(
        text: item['item1'] as String,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      maxWidth = math.max(maxWidth, textPainter.width);
    }
    
    return maxWidth * 1.4;  // simple version
    //final double rotationAngle = rotation * (math.pi / 180); // convert to radians
    //return maxWidth * math.sin(rotationAngle) + maxWidth * math.sin(rotationAngle);
  }
  @override
  Widget build(BuildContext context) {
    final hasValidData = data != null && data!.isNotEmpty && 
        data!.any((item) => (item['item2'] ?? 0) > 0);
    
    if (!hasValidData) {
      return SizedBox(
        height: 500,
        child: Padding(
          padding: padding,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber[700],
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  Text(
                    'Sin datos disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay datos para mostrar en este periodo',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    final barGroups = data!.asMap().entries.map((entry) {
      // default to 0 if null
      final value = (entry.value['item2'] ?? 0);
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),  // to double after null check
            color: barColor,
            width: 30,
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: barColor.withOpacity(0.3),
              width: 2,
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 500,
      child: Padding(
        padding: padding,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            maxY: barGroups.isNotEmpty
                ? barGroups
                    .map((group) => group.barRods.first.toY)
                    .reduce((a, b) => a > b ? a : b)
                : 1,
            groupsSpace: 15,
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value % 1 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: _calculateMaxTitleWidth(data!),
                  getTitlesWidget: (value, meta) {
                    return Container(
                      width: 0,
                      height: 100,
                      padding: const EdgeInsets.only(top: 10),
                      alignment: Alignment.topLeft,
                      child: Transform(
                        alignment: Alignment.topLeft,
                        transform: Matrix4.rotationZ(rotation * (3.1415927 / 180)),
                        child: Text(
                          data![value.toInt()]['item1'] as String,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: tooltipColor,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${data![group.x.toInt()]["item1"]}: ${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}