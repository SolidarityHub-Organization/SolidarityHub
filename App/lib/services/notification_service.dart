import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static Future<List<AppNotification>> fetchUserNotifications(int userId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/notifications/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => AppNotification.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }
}
