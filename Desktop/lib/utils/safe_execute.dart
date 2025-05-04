import 'dart:async';
import 'package:flutter/foundation.dart';

class SafeExecute {
  static Future<T?> runAsync<T>({
    required Future<T> Function() action,
    String? context,
    Function(Object error, StackTrace stackTrace)? onError,
    T? defaultValue,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);

      if (onError != null) {
        onError(error, stackTrace);
      }

      return defaultValue;
    }
  }

  static T? run<T>({
    required T Function() action,
    String? context,
    Function(Object error, StackTrace stackTrace)? onError,
    T? defaultValue,
  }) {
    try {
      return action();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);

      if (onError != null) {
        onError(error, stackTrace);
      }

      return defaultValue;
    }
  }

  static void _logError(Object error, StackTrace stackTrace, String? context) {
    if (kDebugMode) {
      print('╔════════════════════════════════════════');
      print('║ ERROR${context != null ? ' en $context' : ''}');
      print('╟────────────────────────────────────────');
      print('║ ${error.toString()}');
      print('╟────────────────────────────────────────');
      print('║ Stack Trace:');
      print('║ ${stackTrace.toString().split('\n').join('\n║ ')}');
      print('╚════════════════════════════════════════');
    }
  }
}
