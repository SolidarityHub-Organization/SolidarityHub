import 'dart:convert';
import 'package:http/http.dart' as http;

class GeneralService {
  final String baseUrl;

  GeneralService(this.baseUrl);

  DateTime _adjustEndDate(DateTime date) {
    // Para la fecha final, usamos el final del día (23:59:59.999)
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  Future<int> fetchVictimCount(DateTime startDate, DateTime endDate) async {
    // Ajustar las fechas para incluir el día completo
    final adjustedStartDate = _adjustEndDate(startDate);
    final adjustedEndDate = _adjustEndDate(endDate);

    final url =
        '$baseUrl/api/v1/victims/count'
        '?fromDate=${adjustedStartDate.toIso8601String()}'
        '&toDate=${adjustedEndDate.toIso8601String()}';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10)); // Agregar timeout para evitar esperas indefinidas

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return 0; // Devolver 0 en lugar de error si la respuesta está vacía
        }
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener víctimas filtradas: ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('No se pudo conectar al servidor. Verifique que el backend esté en ejecución.');
      }
      throw Exception('Error al conectar con el backend: $e');
    }
  }

  Future<int> fetchVolunteerCount(DateTime startDate, DateTime endDate) async {
    // Ajustar las fechas para incluir el día completo
    final adjustedStartDate = _adjustEndDate(startDate);
    final adjustedEndDate = _adjustEndDate(endDate);

    final url =
        '$baseUrl/api/v1/volunteers/count'
        '?fromDate=${adjustedStartDate.toIso8601String()}'
        '&toDate=${adjustedEndDate.toIso8601String()}';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10)); // Agregar timeout para evitar esperas indefinidas

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return 0; // Devolver 0 en lugar de error si la respuesta está vacía
        }
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener voluntarios filtrados: ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('No se pudo conectar al servidor. Verifique que el backend esté en ejecución.');
      }
      throw Exception('Error al conectar con el backend: $e');
    }
  }

  Future<double> fetchTotalQuantityFiltered(DateTime fromDate, DateTime toDate, {String currency = 'EUR'}) async {
    final String params =
        'currency=$currency&fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';

    final uri = Uri.parse('$baseUrl/api/v1/monetary-donations/total-amount?$params');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Convertir explícitamente el valor a double, cualquiera sea su tipo original
      final dynamic value = json.decode(response.body);
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      } else {
        return 0.0;
      }
    } else {
      throw Exception('Error al obtener el total de donaciones: ${response.statusCode}');
    }
  }

  Future<int> fetchTaskCountByStateFiltered(String state, DateTime startDate, DateTime endDate) async {
    final String params = 'fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';

    final response = await http.get(Uri.parse('$baseUrl/api/v1/tasks/states/$state/count?$params'));

    if (response.statusCode == 200) {
      final int count = json.decode(response.body);
      return count;
    } else {
      return 0; // Devuelve 0 en caso de error como valor predeterminado
    }
  }

  Future<int> fetchRecentActivity(String type, DateTime startDate, DateTime endDate) async {
    final String params = 'fromDate=${startDate.toIso8601String()}&toDate=${endDate.toIso8601String()}';

    final response = await http.get(Uri.parse('$baseUrl/api/v1/tasks/types/$type/count?$params'));

    if (response.statusCode == 200) {
      final int count = json.decode(response.body);
      return count;
    } else {
      return 0; // Devuelve 0 en caso de error como valor predeterminado
    }
  }
}
