import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static Future<List<NotificationModel>> fetchNotifications(int volunteerId) async {
    final url = Uri.parse('http://localhost:5170/api/v1/notifications/volunteer/$volunteerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print (jsonData);
      return jsonData.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar notificaciones');
    }
  }
}

