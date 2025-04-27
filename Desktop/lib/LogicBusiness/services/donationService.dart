import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solidarityhub/LogicPersistence/models/donation.dart';

class DonationService {
  final String baseUrl;

  DonationService(this.baseUrl);

  Future<List<Volunteer>> fetchVolunteers() async {
    final uri = Uri.parse('$baseUrl/api/v1/volunteers');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Volunteer.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar voluntarios: ${response.statusCode}');
    }
  }

  Future<List<Donation>> fetchAllDonations() async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Donation.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar donaciones: ${response.statusCode}');
    }
  }

  Future<Donation> createDonation(Donation donation) async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations');

    if (donation.volunteer == null) {
      throw Exception('Se requiere especificar un voluntario para la donación');
    }

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

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(donationData),
      );

      if (response.statusCode == 201) {
        return Donation.fromJson(json.decode(response.body));
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData is String ? errorData : errorData.toString();
        } catch (e) {
          errorMessage = 'Error al crear donación: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al crear donación: $e');
    }
  }

  Future<Donation> updateDonation(Donation donation) async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations/${donation.id}');

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

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(donationData),
    );

    if (response.statusCode == 200) {
      return Donation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar donación: ${response.statusCode}');
    }
  }

  Future<void> deleteDonation(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations/$id');

    final response = await http.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar donación: ${response.statusCode}');
    }
  }

  Future<Donation> assignDonation(
    int donationId,
    int victimId,
    int quantity,
    DateTime donationDate,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/v1/physical-donations/$donationId/assign',
    );

    final Map<String, dynamic> data = {
      'id': donationId,
      'victim_id': victimId,
      'quantity': quantity,
      'distributed': quantity,
      'donation_date': donationDate.toIso8601String(),
      'volunteer_id': 0,
      'admin_id': 1,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData == null) {
          throw Exception('La respuesta del servidor está vacía');
        }

        // Asegurar que los campos numéricos tienen valores por defecto
        responseData['id'] = responseData['id'] ?? 0;
        responseData['victim_id'] = responseData['victim_id'] ?? 0;
        responseData['volunteer_id'] = responseData['volunteer_id'] ?? 0;
        responseData['admin_id'] = responseData['admin_id'] ?? 1;
        responseData['quantity'] = responseData['quantity'] ?? 0;
        responseData['distributed'] = responseData['distributed'] ?? 0;

        return Donation.fromJson(responseData);
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData is String ? errorData : errorData.toString();
        } catch (e) {
          errorMessage = 'Error al asignar donación: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al asignar donación: $e');
    }
  }

  Future<int> fetchTotalQuantity() async {
    final uri = Uri.parse('$baseUrl/api/v1/physical-donations/total-amount');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as int;
    } else {
      throw Exception(
        'Error al obtener el total de donaciones: ${response.statusCode}',
      );
    }
  }

  Future<List<MonetaryDonation>> fetchAllMonetaryDonations() async {
    final uri = Uri.parse('$baseUrl/api/v1/monetary-donations');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MonetaryDonation.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al cargar donaciones monetarias: ${response.statusCode}',
      );
    }
  }

  Future<MonetaryDonation> createMonetaryDonation(
    MonetaryDonation donation,
  ) async {
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
          errorMessage =
              'Error al crear donación monetaria: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al crear donación monetaria: $e');
    }
  }
}
