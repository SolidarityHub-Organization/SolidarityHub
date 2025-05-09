import 'dart:async';
import 'package:flutter/foundation.dart';

class Logger {
  static Future<T> runAsync<T>(Future<T> Function() action, [String? customErrorMessage]) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, customErrorMessage);
      rethrow;
    }
  }

  static T run<T>(T Function() action, [String? customErrorMessage]) {
    try {
      return action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, customErrorMessage);
      rethrow;
    }
  }

  static void _logError(Object error, StackTrace stackTrace, String? customErrorMessage) {
    if (kDebugMode) {
      print('ERROR${customErrorMessage != null ? ' en $customErrorMessage' : ''}');
      print(error.toString());
      print('Stack Trace:');
      print(stackTrace.toString().split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n'));
      print('');
    }
  }
}
