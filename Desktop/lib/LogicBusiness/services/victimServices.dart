import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicPersistence/models/victim.dart';

class VictimService {
  final String baseUrl;

  VictimService(this.baseUrl);

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

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/map/victims-with-location'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((location) {
          return {
            'id': location['id'],
            'name': location['name'],
            'latitude': location['latitude'],
            'longitude': location['longitude'],
            'type': location['type'],
          };
        }).toList();
      } else {
        print('Error al obtener las ubicaciones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchVictimCountByDate() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/victims/count-by-date'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((need) {
          return {'date': need['item1'], 'num': need['item2']};
        }).toList();
      } else {
        print(
          'Error al obtener el numero de vicitmas por dia: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');
      return [];
    }
  }

  Future<List<Victim>> fetchAllVictims() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/victims'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((victim) => Victim.fromJson(victim)).toList();
      } else {
        throw Exception('Error al obtener víctimas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el backend: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFilteredVictimCounts(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/v1/need-types/victim-counts/filtered'
          '?startDate=${startDate.toIso8601String()}'
          '&endDate=${endDate.toIso8601String()}',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return {'type': item['item1'], 'count': item['item2']};
        }).toList();
      } else {
        throw Exception(
          'Error al obtener víctimas filtradas: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el backend: $e');
    }
  }
}
