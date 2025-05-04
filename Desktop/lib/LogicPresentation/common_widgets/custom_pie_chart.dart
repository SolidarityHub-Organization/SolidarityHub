import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double threshold;
  final ScrollController legendScrollController;
  final EdgeInsetsGeometry padding;

  const CustomPieChart({
    super.key,
    required this.data,
    this.threshold = 10.0,
    required this.legendScrollController,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 50),
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = data.fold<int>(
      0,
      (sum, entry) => sum + (entry['count'] as int),
    );

    final Map<String, int> groupedData = {};
    final Map<String, int> otherItems = {};
    int otherTotal = 0;

    for (var entry in data) {
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
    // Create a combined list of all items for the legend
    final List<MapEntry<String, int>> legendItems = [];
    
    // Add regular items first
    legendItems.addAll(groupedData.entries.where((e) => e.key != 'Other'));
    
    // Add "Other" category with a separator if it exists
    if (otherItems.isNotEmpty) {
      // Add a separator before "Other" items
      if (legendItems.isNotEmpty) {
        legendItems.add(const MapEntry('---', 0)); // Separator
      }
      
      // Add all items from "Other" category
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
                  // Show regular items
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
                  
                  // Add a divider before "Other" items
                  if (otherItems.isNotEmpty && groupedData.entries.any((e) => e.key != 'Other'))
                    const Divider(thickness: 1, height: 24),
                    
                  // Add "Other" section header if there are items in "Other"
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
                    
                  // Show all the items grouped as "Other"
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