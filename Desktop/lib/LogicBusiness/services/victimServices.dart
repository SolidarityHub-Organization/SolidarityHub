import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../LogicPersistence/models/victim.dart';
//import '../../LogicPersistence/models/victimNeedsData.dart';

class VictimService {
  final String baseUrl;

  VictimService(this.baseUrl);

  /*Future<List<Victim>> fetchVictims() async {
    final response = await http.get(Uri.parse('$baseUrl/api/victims'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Victim.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load victims');
    }
  }*/

  /*Future<List<VictimNeedsData>> fetchVictimNeeds() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/need-types/victim-counts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VictimNeedsData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load victim needs data');
    }
  }*/

  Future<List<Map<String, dynamic>>> fetchVictimNeedsCount() async {
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
