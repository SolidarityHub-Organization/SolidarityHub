import 'dart:async';
import 'package:flutter/foundation.dart';

class SafeExecute {
  static Future<T> runAsync<T>(Future<T> Function() action, [String? context]) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);
      rethrow;
    }
  }

  static T run<T>(T Function() action, [String? context]) {
    try {
      return action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);
      rethrow;
    }
  }

  static void _logError(Object error, StackTrace stackTrace, String? context) {
    if (kDebugMode) {
      print('ERROR${context != null ? ' en $context' : ''}');
      print(error.toString());
      print('Stack Trace:');
      print(stackTrace.toString().split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n'));
      print('');
    }
  }
}
