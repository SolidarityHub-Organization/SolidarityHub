import 'dart:convert';
import 'api_services.dart';

class DashboardServices {
  static Future<Map<String, dynamic>> fetchRecentActivity(DateTime startDate, DateTime endDate, int page, int size) async {
    final String params = 'fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}&page=$page&size=$size';
    final response = await ApiServices.get('dashboard/activity-log?$params');
    List<Map<String, dynamic>> activity = [];

    Map<String, dynamic> result = {};

    if (response.statusCode.ok) {
      result = json.decode(response.body);
    }

    return result;
  }
}
