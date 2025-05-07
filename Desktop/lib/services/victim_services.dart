import 'dart:convert';
import 'package:solidarityhub/controllers/general_controller.dart';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/services/api_services.dart';

class VictimServices {
  static Future<List<Map<String, dynamic>>> fetchVictimCountByDate() async {
    final response = await ApiServices.get('victims/count-by-date');
    List<Map<String, dynamic>> victims = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      victims =
          data.map((need) {
            return {'date': need['item1'], 'num': need['item2']};
          }).toList();
    }

    return victims;
  }

  static Future<List<Victim>> fetchAllVictims() async {
    final response = await ApiServices.get('victims');
    List<Victim> victims = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      victims = data.map((victim) => Victim.fromJson(victim)).toList();
    }

    return victims;
  }

  static Future<List<Map<String, dynamic>>> fetchFilteredVictimCounts(DateTime startDate, DateTime endDate) async {
    final response = await ApiServices.get(
      'need-types/victim-counts/filtered'
      '?fromDate=${startDate.toIso8601String()}'
      '&toDate=${endDate.toIso8601String()}',
    );
    List<Map<String, dynamic>> victims = [];

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);
      data.forEach((key, value) {
        victims.add({'type': key, 'count': value});
      });
    }

    return victims;
  }

  static Future<int> fetchVictimCount(DateTime startDate, DateTime endDate) async {
    final adjustedStartDate = GeneralController.adjustEndDate(startDate);
    final adjustedEndDate = GeneralController.adjustEndDate(endDate);
    int count = 0;

    final url =
        'victims/count'
        '?fromDate=${adjustedStartDate.toIso8601String()}'
        '&toDate=${adjustedEndDate.toIso8601String()}';
    final response = await ApiServices.get(url);

    if (response.statusCode.ok) {
      if (response.body.isEmpty) {
        count = 0;
      }

      count = int.parse(response.body);
    } else {
      throw Exception('Error al obtener víctimas filtrados: ${response.statusCode}, Respuesta: ${response.body}');
    }

    return count;
  }
}
