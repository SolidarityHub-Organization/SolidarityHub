// dialogs.dart
import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog(
    BuildContext context, VoidCallback onConfirm) {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<bool> isValid = ValueNotifier(false);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Escribe "ELIMINAR" para confirmar la eliminación de tu cuenta.'),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: (value) {
                isValid.value = value.trim().toUpperCase() == 'ELIMINAR';
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe ELIMINAR',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isValid,
            builder: (context, valid, _) {
              return TextButton(
                onPressed: valid
                    ? () {
                  Navigator.of(context).pop();
                  onConfirm();
                }
                    : null,
                child: Text(
                  'Eliminar',
                  style: TextStyle(
                    color: valid ? Colors.red : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}