import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/models/donation.dart';

import 'api_general_service.dart';

class DonationService {
  final String baseUrl;
  DonationService(this.baseUrl);

  static Future<List<Donation>> fetchAllDonations() async {
    final response = await ApiService.get('physical-donations');
    List<Donation> donations = [];

    if (response.statusCode.ok) {
      final List<dynamic> data = json.decode(response.body);
      donations = data.map((e) => Donation.fromJson(e)).toList();
    }

    return donations;
  }

  static Future<Donation> createDonation(Donation donation) async {
    final Map<String, dynamic> donationData = {
      'item_name': donation.itemName,
      'description': donation.description,
      'item_type': donation.category.name,
      'quantity': donation.donated,
      'victim_id': donation.assignedVictim?.id,
      'volunteer_id': donation.volunteer!.id,
      'admin_id': 1,
      'donation_date': DateTime.now().toIso8601String(),
    };

    final response = await ApiService.post('physical-donations', body: json.encode(donationData));

    if (response.statusCode.ok) {
      return Donation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create donation: $response.body');
    }
  }

  static Future<Donation> updateDonation(Donation donation) async {
    final Map<String, dynamic> donationData = {
      'id': donation.id,
      'item_name': donation.itemName,
      'description': donation.description,
      'item_type': donation.category.index,
      'quantity': donation.donated,
      'victim_id': donation.assignedVictim?.id,
      'volunteer_id': donation.volunteer?.id,
      'admin_id': null,
      'donation_date': DateTime.now().toIso8601String(),
    };

    final response = await ApiService.put('physical-donations/${donation.id}', body: json.encode(donationData));

    if (response.statusCode.ok) {
      return Donation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar donación: ${response.statusCode}');
    }
  }

  static Future<void> deleteDonation(int id) async {
    final response = await ApiService.delete('physical-donations/$id');

    if (!response.statusCode.ok) {
      throw Exception('Error al eliminar donación: ${response.statusCode}');
    }
  }

  static Future<Donation> assignDonation(int donationId, int victimId, int quantity, DateTime donationDate) async {
    final uri = 'physical-donations/$donationId/assign';

    final Map<String, dynamic> data = {
      'id': donationId,
      'victim_id': victimId,
      'quantity': quantity,
      'distributed': quantity,
      'donation_date': donationDate.toIso8601String(),
      'volunteer_id': 0,
      'admin_id': 1,
    };

    final response = await ApiService.post(uri, body: json.encode(data));

    if (response.statusCode.ok) {
      final responseData = json.decode(response.body);

      if (responseData == null) {
        throw Exception('La respuesta del servidor está vacía');
      }

      responseData['id'] = responseData['id'] ?? 0;
      responseData['victim_id'] = responseData['victim_id'] ?? 0;
      responseData['volunteer_id'] = responseData['volunteer_id'] ?? 0;
      responseData['admin_id'] = responseData['admin_id'] ?? 1;
      responseData['quantity'] = responseData['quantity'] ?? 0;
      responseData['distributed'] = responseData['distributed'] ?? 0;

      return Donation.fromJson(responseData);
    } else {
      throw Exception('Error al asignar donación: ${response.body}');
    }
  }

  Future<int> fetchTotalQuantity() async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations/total-amount');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as int;
    } else {
      throw Exception('Error al obtener el total de donaciones: ${response.statusCode}');
    }
  }

  Future<List<MonetaryDonation>> fetchAllMonetaryDonations() async {
    final uri = Uri.parse('$baseUrl/api/v1/monetary-donations');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MonetaryDonation.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar donaciones monetarias: ${response.statusCode}');
    }
  }

  Future<MonetaryDonation> createMonetaryDonation(MonetaryDonation donation) async {
    final uri = Uri.parse('$baseUrl/api/v1/monetary-donations');

    if (donation.volunteer == null) {
      throw Exception('Se requiere especificar un voluntario para la donación');
    }

    final Map<String, dynamic> donationData = {
      'amount': donation.amount,
      'currency': donation.currency.name,
      'payment_service': donation.paymentService.name,
      'payment_status': donation.paymentStatus.name,
      'transaction_id': donation.transactionId,
      'victim_id': donation.assignedVictim?.id,
      'volunteer_id': donation.volunteer!.id,
      'admin_id': 1,
      'donation_date': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(donationData),
      );

      if (response.statusCode == 201) {
        return MonetaryDonation.fromJson(json.decode(response.body));
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData is String ? errorData : errorData.toString();
        } catch (e) {
          errorMessage = 'Error al crear donación monetaria: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al crear donación monetaria: $e');
    }
  }

  static Future<double> fetchTotalQuantityFiltered(
    DateTime fromDate,
    DateTime toDate, {
    String currency = 'EUR',
  }) async {
    final String params =
        'currency=$currency&fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
    final uri = 'monetary-donations/total-amount?$params';
    final response = await ApiService.get(uri);

    if (response.statusCode.ok) {
      final value = json.decode(response.body);

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
}
