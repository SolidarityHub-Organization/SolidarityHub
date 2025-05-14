import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomPieChart extends StatelessWidget {
  final List<Map<String, dynamic>>? data;
  final double threshold;
  final ScrollController legendScrollController;
  final EdgeInsetsGeometry padding;

  const CustomPieChart({
    super.key,
    this.data,
    this.threshold = 10.0,
    required this.legendScrollController,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 50),
  });

  @override
  Widget build(BuildContext context) {
    final hasData = data != null && data!.isNotEmpty;
    
    final totalValue = hasData ? data!.fold<int>(
      0,
      (sum, entry) => sum + (entry['count'] as int),
    ) : 0;
      if (!hasData || totalValue == 0) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 1,
                        title: 'Sin datos\ndisponibles',
                        color: Colors.grey,
                        radius: 120,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    ],
                    centerSpaceRadius: 50,
                    sectionsSpace: 0,
                    pieTouchData: PieTouchData(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
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
          ],
        ),
      );
    }

    final Map<String, int> groupedData = {};
    final Map<String, int> otherItems = {};
    int otherTotal = 0;

    for (var entry in data!) {
      double percentage = (entry['count'] as int) / totalValue * 100;
      if (percentage < threshold) {
        otherItems[(entry['type'] as String)] = entry['count'] as int;
        otherTotal += entry['count'] as int;
      } else {
        groupedData[(entry['type'] as String)] = entry['count'] as int;
      }
    }

    if (otherTotal > 0) {
      groupedData['Other'] = otherTotal;
    }

    final pieSections = groupedData.entries.map((entry) {
      final percentage = (entry.value / totalValue * 100);
      final isOther = entry.key == 'Other';
      
      String displayTitle = isOther ? 'Otros' : entry.key;
      if (displayTitle.length > 10) {
        displayTitle = '${displayTitle.substring(0, 10)}...';
      }
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: displayTitle,
        color: isOther
            ? Colors.grey
            : Colors.primaries[groupedData.keys.toList().indexOf(entry.key) %
                Colors.primaries.length],
        radius: 120,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
        badgeWidget: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 8,
                  pieTouchData: PieTouchData(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildLegend(groupedData, otherItems, totalValue),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    Map<String, int> groupedData,
    Map<String, int> otherItems,
    int totalValue,
  ) {
    if (totalValue == 0) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // combined list of all items for the legend
    final List<MapEntry<String, int>> legendItems = [];
    
    // regular items first
    legendItems.addAll(groupedData.entries.where((e) => e.key != 'Other'));
    
    // other category with a separator if it exists
    if (otherItems.isNotEmpty) {
      if (legendItems.isNotEmpty) {
        legendItems.add(const MapEntry('---', 0));
      }
      
      legendItems.addAll(otherItems.entries);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 350),
        child: Scrollbar(
          controller: legendScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: legendScrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // regular items
                  ...groupedData.entries
                      .where((e) => e.key != 'Other')
                      .map((entry) {
                    final percentage = (entry.value / totalValue * 100);
                    return _buildLegendItem(
                      entry,
                      percentage,
                      false,
                      groupedData,
                    );
                  }),
                  
                  // divider before other
                  if (otherItems.isNotEmpty && groupedData.entries.any((e) => e.key != 'Other'))
                    const Divider(thickness: 1, height: 24),
                    
                  // other header if there are items
                  if (otherItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        otherItems.length == 1
                          ? 'Otros (1 Elemento)'
                          : 'Otros (${otherItems.length} Elementos)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                  // items grouped as other
                  ...otherItems.entries.map((entry) {
                    final percentage = (entry.value / totalValue * 100);
                    return _buildLegendItem(
                      entry,
                      percentage,
                      true, // isInOther
                      groupedData,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    MapEntry<String, int> entry,
    double percentage,
    bool isInOther,
    Map<String, int> groupedData,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isInOther ? Colors.grey[700] : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  isInOther
                      ? Colors.grey
                      : Colors.primaries[groupedData.keys
                              .toList()
                              .indexOf(entry.key) %
                          Colors.primaries.length],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isInOther ? Colors.grey[700] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}