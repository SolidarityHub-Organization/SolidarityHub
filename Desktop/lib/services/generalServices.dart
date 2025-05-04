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
          .timeout(
            const Duration(seconds: 10),
          ); // Agregar timeout para evitar esperas indefinidas

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return 0; // Devolver 0 en lugar de error si la respuesta está vacía
        }
        return int.parse(response.body);
      } else {
        throw Exception(
          'Error al obtener víctimas filtradas: ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'No se pudo conectar al servidor. Verifique que el backend esté en ejecución.',
        );
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
          .timeout(
            const Duration(seconds: 10),
          ); // Agregar timeout para evitar esperas indefinidas

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return 0; // Devolver 0 en lugar de error si la respuesta está vacía
        }
        return int.parse(response.body);
      } else {
        throw Exception(
          'Error al obtener voluntarios filtrados: ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'No se pudo conectar al servidor. Verifique que el backend esté en ejecución.',
        );
      }
      throw Exception('Error al conectar con el backend: $e');
    }
  }
}
