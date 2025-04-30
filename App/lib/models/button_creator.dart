import 'package:flutter/material.dart';

Widget buildCustomButton(
    String text,
    VoidCallback onPressed, {
      double verticalPadding = 16,
      double horizontalPadding = 20,
      Color backgroundColor = Colors.red,
    }) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}