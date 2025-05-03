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

Widget buildButton(String text) {
  return ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      padding: EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      minimumSize: Size(double.infinity, 0),
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}