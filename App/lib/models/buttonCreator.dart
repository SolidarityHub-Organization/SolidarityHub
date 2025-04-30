import 'package:flutter/material.dart';

Widget buildCustomButton(String text, VoidCallback onPressed, double vertical, double horizontal) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}