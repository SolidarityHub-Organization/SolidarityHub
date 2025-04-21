import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskTableService {
  final String baseUrl;

  TaskTableService(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchTaskProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/need-types/victim-counts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load victim needs count');
    }
  }
}
