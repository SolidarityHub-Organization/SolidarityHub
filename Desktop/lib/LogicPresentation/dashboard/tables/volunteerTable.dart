import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../LogicBusiness/services/volunteerServices.dart';
import 'dart:math' as math;

class VolunteerTab extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const VolunteerTab({
    Key? key,
    required this.fechaFin,
    required this.fechaInicio,
  }) : super(key: key);

  @override
  _VolunteerTabState createState() => _VolunteerTabState();
}

class _VolunteerTabState extends State<VolunteerTab> {
  late Future<List<Map<String, dynamic>>> _volunteerNeedsFuture;
  final VolunteerService _volunteerService = VolunteerService(
    'http://localhost:5170',
  );

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _legendScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = widget.fechaInicio ?? now.subtract(const Duration(days: 365));
    final end = widget.fechaFin ?? now;
    _volunteerNeedsFuture = _volunteerService.fetchFilteredVolunteerSkillsCount(start, end);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _legendScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double _calculateMaxTitleWidth(List<Map<String, dynamic>> data) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    double maxWidth = 0;
    for (var item in data) {
      textPainter.text = TextSpan(
        text: item['item1'] as String,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      maxWidth = math.max(maxWidth, textPainter.width);
    }
    return maxWidth * 1;  // add a % of padding
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TwoDimensionalScrollWidget(
          child: Container(
            constraints: BoxConstraints(
              minWidth: math.max(800, constraints.maxWidth),
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Container(
                width: math.max(800, constraints.maxWidth),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _volunteerNeedsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    } else {
                      final data = snapshot.data!;
                      final barGroups =
                          data
                              .asMap()
                              .entries
                              .map(
                                (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (entry.value['item2'] as int).toDouble(),
                                      color: const Color(0xFFF44336),
                                      width: 30,
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(70, 103, 0, 0),
                                        width: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList();

                      final totalValue = data.fold<int>(
                        0,
                        (sum, entry) => sum + (entry['item2'] as int),
                      );

                      final double threshold = 10.0;  // minimum percentage threshold

                      final Map<String, int> groupedData = {};
                      int otherTotal = 0;

                      for (var entry in data) {
                        double percentage = (entry['item2'] as int) / totalValue * 100;
                        if (percentage < threshold) {
                          otherTotal += entry['item2'] as int;
                        } else {
                          groupedData[entry['item1'] as String] = entry['item2'] as int;
                        }
                      }

                      if (otherTotal > 0) {
                        groupedData['Other'] = otherTotal;
                      }

                      final pieSections = groupedData.entries.map(
                        (entry) => PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: entry.key.length > 10 
                              ? '${entry.key.substring(0, 10)}...'
                              : entry.key,
                          color: entry.key == 'Other' 
                              ? Colors.grey 
                              : Colors.primaries[groupedData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
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
                              '${(entry.value / totalValue * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          badgePositionPercentageOffset: 1.3,
                        ),
                      ).toList();

                      // map to store the original data before grouping
                      final Map<String, int> originalData = {};
                      for (var entry in data) {
                        originalData[entry['item1'] as String] = entry['item2'] as int;
                      }

                      return Column(
                        children: [
                          const Text(
                            'Voluntarios y sus habilidades',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Bar Chart
                          SizedBox(
                            height: 500,
                            width: math.max(800, constraints.maxWidth - 16),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40.0, 0, 20.0, 40.0),
                              child: BarChart(
                                BarChartData(
                                  barGroups: barGroups,
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
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
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
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: _calculateMaxTitleWidth(data),
                                        getTitlesWidget: (value, meta) {
                                          return Container(
                                            width: 0,
                                            height: 100, 
                                            padding: const EdgeInsets.only(top: 10),
                                            alignment: Alignment.topCenter,
                                            child: Transform(
                                              alignment: Alignment.topCenter,
                                              transform: Matrix4.rotationZ(45 * (3.1415927 / 180)),
                                              child: Text(
                                                data[value.toInt()]['item1'] as String,
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
                                      tooltipBgColor: const Color(0xFFF44336),
                                      getTooltipItem: (
                                        group,
                                        groupIndex,
                                        rod,
                                        rodIndex,
                                      ) {
                                        return BarTooltipItem(
                                          '${data[group.x.toInt()]['item1']}: ${rod.toY.toInt()}',
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
                          ),
                          const SizedBox(height: 30),
                          // pie chart and legend
                          SizedBox(
                            height: 400,
                            width: math.max(800, constraints.maxWidth - 16), 
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(50.0, 0.0, 30.0, 50.0),
                                      child: PieChart(
                                        PieChartData(
                                          sections: pieSections,
                                          centerSpaceRadius: 50,
                                          sectionsSpace: 8,
                                          pieTouchData: PieTouchData(
                                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                              // could add touch instructions here for pie chart
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // legend
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 350,
                                      ),
                                      child: Scrollbar(
                                        controller: _legendScrollController,
                                        thumbVisibility: true,
                                        child: SingleChildScrollView(
                                          controller: _legendScrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // main items
                                                ...originalData.entries
                                                    .where((entry) => (entry.value / totalValue * 100) >= threshold)
                                                    .map((entry) {
                                                  final double percentage = (entry.value / totalValue * 100);
                                                  return _buildLegendItem(entry, percentage, false, groupedData);
                                                }),
                                                // divider
                                                if (originalData.entries.any((entry) => (entry.value / totalValue * 100) < threshold))
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 266,
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 8.0),
                                                          child: Divider(
                                                            height: 1,
                                                            thickness: 1,
                                                            color: Colors.black26,
                                                            indent: 0,
                                                            endIndent: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                // "Other" items
                                                ...originalData.entries
                                                    .where((entry) => (entry.value / totalValue * 100) < threshold)
                                                    .map((entry) {
                                                  final double percentage = (entry.value / totalValue * 100);
                                                  return _buildLegendItem(entry, percentage, true, groupedData);
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildLegendItem(MapEntry<String, int> entry, double percentage, bool isInOther, Map<String, int> groupedData) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      children: [
        Row(
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
                        : Colors.primaries[
                            groupedData.keys.toList().indexOf(entry.key) %
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
      ],
    ),
  );
}

class TwoDimensionalScrollWidget extends StatefulWidget {
  final Widget child;

  const TwoDimensionalScrollWidget({
    super.key,
    required this.child,
  });

  @override
  State<TwoDimensionalScrollWidget> createState() => _TwoDimensionalScrollWidgetState();
}

class _TwoDimensionalScrollWidgetState extends State<TwoDimensionalScrollWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      trackVisibility: false,
      thumbVisibility: false,
      interactive: true,
      controller: _verticalController,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: Scrollbar(
        trackVisibility: false,
        thumbVisibility: false,
        interactive: true,
        controller: _horizontalController,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        notificationPredicate: (notif) => notif.depth == 1,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
