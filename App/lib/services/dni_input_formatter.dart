import 'package:flutter/services.dart';

class DniInputFormatter extends TextInputFormatter {
  final RegExp _dniRegex = RegExp(r'^\d{0,8}[A-Z]?$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (_dniRegex.hasMatch(newValue.text.toUpperCase())) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return oldValue;
  }
}
