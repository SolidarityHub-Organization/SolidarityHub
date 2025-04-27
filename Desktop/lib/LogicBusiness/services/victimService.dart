import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicPersistence/models/victim.dart';

class VictimService {
  final String baseUrl;

  VictimService(this.baseUrl);

  Future<List<Victim>> getAllVictims() async {
    final uri = Uri.parse('$baseUrl/api/v1/victims');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Victim.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar afectados: ${response.statusCode}');
    }
  }

  Future<Victim> getVictimById(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/victims/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Victim.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar afectado: ${response.statusCode}');
    }
  }
}
