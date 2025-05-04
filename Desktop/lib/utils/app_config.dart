import 'package:flutter/foundation.dart';

class AppConfig {
  String get apiBaseUrl => 'http://localhost:5170/api/v1';

  bool get isDebugMode => kDebugMode;
}
