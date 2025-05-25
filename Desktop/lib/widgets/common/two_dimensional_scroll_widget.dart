import 'package:flutter/material.dart';

class TwoDimensionalScrollWidget extends StatefulWidget {
  final Widget child;

  const TwoDimensionalScrollWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<TwoDimensionalScrollWidget> createState() => _TwoDimensionalScrollWidgetState();
}

class _TwoDimensionalScrollWidgetState extends State<TwoDimensionalScrollWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(scrollDirection: Axis.vertical, child: widget.child),
    );
  }
}
