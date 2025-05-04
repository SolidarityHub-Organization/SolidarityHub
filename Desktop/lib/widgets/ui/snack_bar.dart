import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class AppSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show({
    BuildContext? context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final scaffoldMessenger = context != null ? ScaffoldMessenger.of(context) : messengerKey.currentState;

    if (scaffoldMessenger == null) {
      debugPrint('No se pudo encontrar un ScaffoldMessenger válido para mostrar la SnackBar');
      return;
    }

    scaffoldMessenger.hideCurrentSnackBar();

    final Color backgroundColor;
    final Color textColor = Colors.white;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}
