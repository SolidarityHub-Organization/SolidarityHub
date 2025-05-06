import 'dart:convert';
import 'api_general_service.dart';

class DashboardServices {
  static Future<List<Map<String, dynamic>>> fetchRecentActivity(DateTime startDate, DateTime endDate) async {
    final String params = 'fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';
    final response = await ApiService.get('dashboard/activity-log?$params');
    List<Map<String, dynamic>> activity = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);

      activity =
          data
              .map(
                (item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'amount': item['amount'],
                  'type': item['type'],
                  'date': DateTime.parse(item['date']),
                  'currency': item['currency'],
                },
              )
              .toList();
    }

    return activity;
  }
}
