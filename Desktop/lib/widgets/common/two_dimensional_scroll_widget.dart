import 'package:flutter/material.dart';

class TwoDimensionalScrollWidget extends StatefulWidget {
  final Widget child;
  const TwoDimensionalScrollWidget({super.key, required this.child});

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