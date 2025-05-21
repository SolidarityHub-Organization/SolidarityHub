import 'dart:convert';
import 'package:solidarityhub/services/api_services.dart';

class NeedServices {
  static Future<Map<String, dynamic>> fetchNeedByVictimId(int id) async {
    final response = await ApiServices.get('needs/victim/$id');

    if (response.statusCode.ok) {
      return json.decode(response.body);
    }

    return {};
  }
}
