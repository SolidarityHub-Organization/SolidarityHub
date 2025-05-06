import 'dart:convert';
import 'package:solidarityhub/models/victim.dart';
import 'package:solidarityhub/services/api_service.dart';

class VictimService {
  final String baseUrl;
  VictimService(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchVictimCountByDate() async {
    final response = await ApiService.get('victims/count-by-date');
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

  Future<List<Victim>> fetchAllVictims() async {
    final response = await ApiService.get('victims');
    List<Victim> victims = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      victims = data.map((victim) => Victim.fromJson(victim)).toList();
    }

    return victims;
  }

  Future<List<Map<String, dynamic>>> fetchFilteredVictimCounts(DateTime startDate, DateTime endDate) async {
    final response = await ApiService.get(
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
}
