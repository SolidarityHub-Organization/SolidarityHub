import 'package:http/http.dart' as http;

class PopulateDatabase {
  static final client = http.Client();

  static Future<void> populateDatabase() async {
    try {
      final response = await client.post(
        Uri.parse('http://localhost:5170/api/v1/database/populate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error when populating database: ${response.body}');
      }
    } catch (e) {
      print('Error when populating database: $e');
    }
  }

  static Future<void> clearDatabase() async {
    try {
      final response = await client.delete(
        Uri.parse('http://localhost:5170/api/v1/database'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error when clearing database data: ${response.body}');
      }

      print('Database cleared successfully.');
    } catch (e) {
      print('Error when clearing database data: $e');
    }
  }
}
