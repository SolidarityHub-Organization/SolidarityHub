import 'package:solidarityhub/services/api_services.dart';

class DatabaseServices {
  static Future<void> populateDatabase() async {
    final response = await ApiServices.post('database/populate');

    if (!response.statusCode.ok) {
      throw Exception('Error when populating database: ${response.body}');
    }

    print('Database populated successfully.');
  }

  static Future<void> clearDatabase() async {
    final response = await ApiServices.delete('database');

    if (!response.statusCode.ok) {
      throw Exception('Error when clearing database data: ${response.body}');
    }

    print('Database cleared successfully.');
  }

  static Future<void> superPopulateDatabase() async {
    final response = await ApiServices.post('database/superpopulate');

    if (!response.statusCode.ok) {
      throw Exception('Error when superpopulating database: ${response.body}');
    }

    print('Database superpopulated successfully.');
  }
}
