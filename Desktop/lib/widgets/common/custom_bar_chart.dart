import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class CustomBarChart extends StatelessWidget {
  final List<Map<String, dynamic>>? data;
  final Color barColor;
  final Color tooltipColor;
  final EdgeInsetsGeometry padding;
  final String? title;
  final double titleBottomMargin;
  final double threshold;
  final ScrollController? legendScrollController;

  final double rotation = 45.0; // in degrees
  const CustomBarChart({
    super.key,
    this.data,
    this.barColor = const Color(0xFFF44336),
    this.tooltipColor = const Color(0xFFF44336),
    this.padding = const EdgeInsets.fromLTRB(40.0, 0.0, 50.0, 50.0),
    this.title,
    this.titleBottomMargin = 25.0,
    this.threshold = 10.0,  // threshold for "Others" representing the percentage an items makes up from the total item set
    this.legendScrollController,
  });

  List<Map<String, dynamic>> _processDataWithThreshold(List<Map<String, dynamic>> rawData) {
  if (rawData.isEmpty || rawData.length <= 1) return rawData;
  
  final totalValue = rawData.fold<double>(
    0, (sum, entry) => sum + (entry['item2'] as num).toDouble()
  );
  
  if (totalValue <= 0) return rawData;
  
  final sortedData = List<Map<String, dynamic>>.from(rawData);
  
  final List<Map<String, dynamic>> mainItems = [];
  final List<Map<String, dynamic>> otherItems = [];
  
  for (var entry in sortedData) {
    final percentage = (entry['item2'] as num).toDouble() / totalValue * 100;
    
    if (percentage < threshold) {
      otherItems.add(entry);
    } else {
      mainItems.add(entry);
    }
  }
  
  if (mainItems.length < 2 && sortedData.length >= 2) {
    mainItems.clear();
    mainItems.addAll(sortedData.sublist(0, 2));
    otherItems.clear();
    if (sortedData.length > 2) {
      otherItems.addAll(sortedData.sublist(2));
    }
  }
  
  if (otherItems.isNotEmpty) {
    final double othersValue = otherItems.fold<double>(
      0, (sum, entry) => sum + (entry['item2'] as num).toDouble()
    );
    
    mainItems.add({
      'item1': 'Otros',
      'item2': othersValue,
      'isOthers': true,
      'otherItems': otherItems,
    });
  }
  
  return mainItems;
  }

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
  }  
  
  Widget _buildOthersLegend(List<dynamic> otherItemsList, double totalValue) {
    if (otherItemsList.isEmpty) {
      return const SizedBox();
    }
    
    List<Map<String, dynamic>> otherItems = [];
    
    for (var item in otherItemsList) {
      if (item is Map<String, dynamic>) {
        otherItems.add(item);
      }
    }
    
    if (otherItems.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: const BoxDecoration(
            // transparent background, no color
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            otherItems.length == 1
              ? 'Otros (1 Elemento)'
              : 'Otros (${otherItems.length} Elementos)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),        const Divider(thickness: 1, height: 1),
        Expanded( // expanded to make the legend as tall as the chart
          child: Scrollbar(
            controller: legendScrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: legendScrollController,
              itemCount: otherItems.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final item = otherItems[index];
                final percentage = (item['item2'] as num).toDouble() / totalValue * 100;
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['item1'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(Colors.grey),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

double _calculateMaxYLabelWidth(double maxY, double interval) {
  maxY = math.max(maxY, 1.0);
  
  int maxDigits = maxY.toInt().toString().length;
  return (maxDigits * 10.0) + 15.0;
}

  @override
  Widget build(BuildContext context) {
    final hasValidData = data != null && data!.isNotEmpty && 
        data!.any((item) => (item['item2'] ?? 0) > 0);
    
    final processedData = hasValidData 
        ? _processDataWithThreshold(data!) 
        : [];
    
    final double maxY = processedData.isNotEmpty
      ? processedData.map((item) => (item['item2'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b)
      : 1;

    double yAxisInterval;
    if (maxY > 20) {
      double rawInterval = (maxY / 10).ceilToDouble();
      yAxisInterval = (rawInterval % 5 == 0)
          ? rawInterval
          : (rawInterval + (5 - rawInterval % 5));
    } else {
      yAxisInterval = (maxY / 10).ceilToDouble().clamp(1, double.infinity);
    }
    
    final yAxisWidth = _calculateMaxYLabelWidth(maxY, yAxisInterval);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(60.0, 16.0, 60.0, titleBottomMargin),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        SizedBox(
          height: 500,
          child: Padding(
            padding: padding,
            child: hasValidData 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: BarChart(
                        BarChartData(
                          barGroups: processedData.asMap().entries.map((entry) {
                            final value = (entry.value['item2'] ?? 0);
                            final isOthers = entry.value['isOthers'] == true;
                            
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: value.toDouble(),
                                  color: isOthers ? Colors.grey : barColor,
                                  width: 30,
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: (isOthers ? Colors.grey : barColor).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          maxY: processedData.isNotEmpty
                              ? processedData
                                  .map((item) => (item['item2'] ?? 0).toDouble())
                                  .reduce((a, b) => a > b ? a : b) * 1.1
                              : 1,
                          groupsSpace: 15,
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: yAxisInterval,
                                reservedSize: yAxisWidth,
                                getTitlesWidget: (value, meta) {
                                  if (value % yAxisInterval == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        softWrap: false,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.visible,
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
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: processedData.isEmpty 
                                    ? 40 
                                    : _calculateMaxTitleWidth(List<Map<String, dynamic>>.from(processedData)),
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= processedData.length) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return Container(
                                    width: 0,
                                    height: 100,
                                    padding: const EdgeInsets.only(top: 10),
                                    alignment: Alignment.topLeft,
                                    child: Transform(
                                      alignment: Alignment.topLeft,
                                      transform: Matrix4.rotationZ(rotation * (3.1415927 / 180)),
                                      child: Text(
                                        processedData[index]['item1'] as String,
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
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: tooltipColor,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final index = group.x.toInt();
                                if (index < 0 || index >= processedData.length) {
                                  return null;
                                }
                                
                                final item = processedData[index];
                                final isOthers = item['isOthers'] == true;
                                
                                return BarTooltipItem(
                                  isOthers 
                                    ? 'Otros: ${rod.toY.toInt()}'
                                    : '${item["item1"]}: ${rod.toY.toInt()}',
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
                    if (processedData.any((item) => item['isOthers'] == true) && legendScrollController != null)
                      Container(
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: _buildOthersLegend(
                          (processedData.firstWhere(
                            (item) => item['isOthers'] == true, 
                            orElse: () => {'otherItems': []}
                          )['otherItems'] as List<dynamic>? ?? []),
                          processedData.fold<double>(0, (sum, item) => sum + (item['item2'] as num).toDouble()),
                        ),
                      ),
                  ],
                )
              : Center(
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
        ),
      ],
    );
  }
}