import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class CustomLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> xLabels;
  final Color lineColor;
  final Color areaColor;
  final String title;
  final EdgeInsetsGeometry padding;

  final double rotation = 45.0; // in degrees


  const CustomLineChart({
    super.key,
    required this.spots,
    required this.xLabels,
    this.lineColor = Colors.red,
    this.areaColor = const Color(0x4DFF0000),
    this.title = '',
    this.padding = const EdgeInsets.fromLTRB(60.0, 0.0, 60.0, 50.0),
  });

  // Add a helper method to calculate max title width
  double _calculateMaxTitleWidth(BuildContext context, List<String> labels) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    double maxWidth = 0;
    for (var label in labels) {
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      maxWidth = math.max(maxWidth, textPainter.width);
    }

    //return maxWidth * 1.4;  // simple version
    final double rotationAngle = rotation * (math.pi / 180);  // convert to radians
    return maxWidth * math.cos(rotationAngle) + maxWidth * math.sin(rotationAngle);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate reserved size for bottom labels
    final bottomReservedSize = _calculateMaxTitleWidth(context, xLabels);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(60.0, 16.0, 60.0, 0.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        Padding(
          padding: padding,
          child: SizedBox(
            height: 400,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    preventCurveOverShooting: true,
                    preventCurveOvershootingThreshold: 1.0,
                    belowBarData: BarAreaData(
                      show: true,
                      color: areaColor,
                      cutOffY: 0,
                      applyCutOffY: true,
                      spotsLine: BarAreaSpotsLine(
                        show: true,
                        flLineStyle: FlLine(
                          color: lineColor.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    isStrokeCapRound: true,
                  ),
                ],
                minX: 0,
                maxX: spots.isNotEmpty ? (spots.length - 1).toDouble() : 0,
                minY: 0,
                maxY: spots.isNotEmpty
                    ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
                    : 1,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: bottomReservedSize, // Use the calculated size here
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < xLabels.length) {
                          return Container(
                            width: 0, // Let the text define width
                            height: 100,
                            padding: const EdgeInsets.only(top: 10),
                            alignment: Alignment.topCenter,
                            child: Transform(
                              alignment: Alignment.topCenter,
                              transform: Matrix4.rotationZ(rotation * (3.1415927 / 180)),
                              child: Text(
                                xLabels[index],
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
                        }
                        return const SizedBox.shrink();
                      },
                      interval: 1,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: lineColor,
                    tooltipPadding: const EdgeInsets.all(8.0),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}