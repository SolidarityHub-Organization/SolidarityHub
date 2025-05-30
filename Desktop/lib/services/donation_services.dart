import 'dart:convert';
import 'package:solidarityhub/models/donation.dart';
import 'package:http/http.dart' as http;

import 'api_services.dart';

class DonationServices {
  static String baseUrl = 'http://localhost:5170'; // Ajusta si es necesario

  static Future<List<Donation>> fetchAllDonations() async {
    try {
      final response = await ApiServices.get('physical-donations');
      List<Donation> donations = [];

      if (response.statusCode.ok) {
        final List<dynamic> data = json.decode(response.body);
        donations = data.map((e) => Donation.fromJson(e)).toList();
      } else {
        throw Exception('No se pudieron cargar las donaciones. Por favor, inténtelo de nuevo más tarde.');
      }

      return donations;
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al cargar las donaciones: ${e.toString()}');
      }
      throw Exception('Error inesperado al cargar las donaciones. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<Donation> createDonation(Donation donation) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/physical-donations');
      final donationData = {
        'item_name': donation.itemName,
        'description': donation.description,
        'item_type': donation.category.index,
        'quantity': donation.donated,
        'victim_id': donation.assignedVictim?.id,
        'volunteer_id': donation.volunteer?.id,
        'admin_id': 1,
        'donation_date': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(donationData),
      );

      if (response.statusCode == 201) {
        return Donation.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception(
          'Los datos de la donación no son válidos. Por favor, revise la información e inténtelo de nuevo.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró el voluntario o la víctima especificada.');
      } else {
        throw Exception('Error al crear la donación. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al crear la donación: ${e.toString()}');
      }
      throw Exception('Error inesperado al crear la donación. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<Donation> updateDonation(Donation donation) async {
    try {
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

      final response = await ApiServices.put('physical-donations/${donation.id}', body: json.encode(donationData));

      if (response.statusCode.ok) {
        return Donation.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró la donación especificada.');
      } else if (response.statusCode == 400) {
        throw Exception(
          'Los datos de la donación no son válidos. Por favor, revise la información e inténtelo de nuevo.',
        );
      } else {
        throw Exception('Error al actualizar la donación. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al actualizar la donación: ${e.toString()}');
      }
      throw Exception('Error inesperado al actualizar la donación. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<void> deleteDonation(int id) async {
    try {
      final response = await ApiServices.delete('physical-donations/$id');

      if (!response.statusCode.ok) {
        if (response.statusCode == 404) {
          throw Exception('No se encontró la donación especificada.');
        } else if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar esta donación.');
        } else {
          throw Exception('Error al eliminar la donación. Por favor, inténtelo de nuevo más tarde.');
        }
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al eliminar la donación: ${e.toString()}');
      }
      throw Exception('Error inesperado al eliminar la donación. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<Donation> assignDonation(int donationId, int victimId, int quantity, DateTime donationDate) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/physical-donations/$donationId/assign');
      final data = {
        'victim_id': victimId,
        'donation_date': donationDate.toIso8601String(),
        'volunteer_id': 0,
        'admin_id': 1,
      };

      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(data));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Donation.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró la donación o la víctima especificada.');
      } else if (response.statusCode == 400) {
        throw Exception('La cantidad asignada no es válida o excede la cantidad disponible.');
      } else {
        throw Exception('Error al asignar la donación. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al asignar la donación: ${e.toString()}');
      }
      throw Exception('Error inesperado al asignar la donación. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<Donation> unassignDonation(int donationId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/physical-donations/$donationId/unassign');
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Donation.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró la donación especificada.');
      } else {
        throw Exception('Error al cancelar la asignación. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al cancelar la asignación: ${e.toString()}');
      }
      throw Exception('Error inesperado al cancelar la asignación. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<int> fetchTotalPhysicalDonationsQuantity(DateTime fromDate, DateTime toDate) async {
    try {
      final String params = 'fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
      final uri = 'physical-donations/total-amount?$params';

      final response = await ApiServices.get(uri);

      if (response.statusCode.ok) {
        final value = json.decode(response.body);
        return value;
      } else {
        throw Exception('Error al obtener el total de recursos donados. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al obtener el total de recursos donados: ${e.toString()}');
      }
      throw Exception(
        'Error inesperado al obtener el total de recursos donados. Por favor, inténtelo de nuevo más tarde.',
      );
    }
  }

  static Future<List<MonetaryDonation>> fetchAllMonetaryDonations() async {
    try {
      final response = await ApiServices.get('monetary-donations');

      if (response.statusCode.ok) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => MonetaryDonation.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar las donaciones monetarias. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al cargar las donaciones monetarias: ${e.toString()}');
      }
      throw Exception('Error inesperado al cargar las donaciones monetarias. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<MonetaryDonation> createMonetaryDonation(MonetaryDonation donation) async {
    try {
      if (donation.volunteer == null) {
        throw Exception('Se requiere especificar un voluntario para la donación.');
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

      final response = await ApiServices.post('monetary-donations', body: donationData);

      if (response.statusCode.ok) {
        return MonetaryDonation.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception(
          'Los datos de la donación monetaria no son válidos. Por favor, revise la información e inténtelo de nuevo.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró el voluntario o la víctima especificada.');
      } else {
        throw Exception('Error al crear la donación monetaria. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al crear la donación monetaria: ${e.toString()}');
      }
      throw Exception('Error inesperado al crear la donación monetaria. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<double> fetchTotalQuantityFiltered(
    DateTime fromDate,
    DateTime toDate, {
    String currency = 'EUR',
  }) async {
    try {
      final String params =
          'currency=$currency&fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
      final uri = 'monetary-donations/total-amount?$params';
      final response = await ApiServices.get(uri);

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
        throw Exception('Error al obtener el total de donaciones monetarias. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al obtener el total de donaciones monetarias: ${e.toString()}');
      }
      throw Exception(
        'Error inesperado al obtener el total de donaciones monetarias. Por favor, inténtelo de nuevo más tarde.',
      );
    }
  }

  static Future<void> deleteMonetaryDonation(int id) async {
    try {
      final response = await ApiServices.delete('monetary-donations/$id');

      if (!response.statusCode.ok) {
        if (response.statusCode == 404) {
          throw Exception('No se encontró la donación monetaria especificada.');
        } else if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar esta donación monetaria.');
        } else {
          throw Exception('Error al eliminar la donación monetaria. Por favor, inténtelo de nuevo más tarde.');
        }
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al eliminar la donación monetaria: ${e.toString()}');
      }
      throw Exception('Error inesperado al eliminar la donación monetaria. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<int> fetchTotalDonors(DateTime fromDate, DateTime toDate) async {
    try {
      final String params = 'fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
      final uri = 'donations/total-donors?$params';

      final response = await ApiServices.get(uri);

      if (response.statusCode.ok) {
        final value = json.decode(response.body);
        return value;
      } else {
        throw Exception('Error al obtener el total de donantes. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al obtener el total de donantes: ${e.toString()}');
      }
      throw Exception('Error inesperado al obtener el total de donantes. Por favor, inténtelo de nuevo más tarde.');
    }
  }

  static Future<Map<String, int>> fetchPhysicalDonationsTotalAmountByType(DateTime fromDate, DateTime toDate) async {
    try {
      final String params = 'fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
      final uri = 'physical-donations/total-by-type?$params';

      final response = await ApiServices.get(uri);

      if (response.statusCode.ok) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Error al obtener el total de donaciones por tipo. Por favor, inténtelo de nuevo más tarde.');
      }
    } catch (e) {
      if (e is Exception) {
        throw Exception('Error al obtener el total de donaciones por tipo: ${e.toString()}');
      }
      throw Exception(
        'Error inesperado al obtener el total de donaciones por tipo. Por favor, inténtelo de nuevo más tarde.',
      );
    }
  }

  static Future<Map<String, double>> fetchPhysicalDonationsSumByWeek(DateTime fromDate, DateTime toDate) async {
    final String params = 'fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
    final uri = 'physical-donations/sum-by-week?$params';

    final response = await ApiServices.get(uri);

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);

      Map<String, double> result = {};
      data.forEach((key, value) {
        if (value is double) {
          result[key] = value;
        } else if (value is int) {
          result[key] = value.toDouble();
        } else {
          result[key] = 0.0;
        }
      });

      return result;
    } else {
      throw Exception('Error al obtener la suma de donaciones físicas por semana: ${response.statusCode}');
    }
  }

  static Future<Map<String, double>> fetchMonetaryDonationsSumByWeek(DateTime fromDate, DateTime toDate) async {
    final String params = 'fromDate=${fromDate.toIso8601String()}&toDate=${toDate.toIso8601String()}';
    final uri = 'monetary-donations/sum-by-week?$params';

    final response = await ApiServices.get(uri);

    if (response.statusCode.ok) {
      final Map<String, dynamic> data = json.decode(response.body);

      Map<String, double> result = {};
      data.forEach((key, value) {
        if (value is double) {
          result[key] = value;
        } else if (value is int) {
          result[key] = value.toDouble();
        } else {
          result[key] = 0.0;
        }
      });

      return result;
    } else {
      throw Exception('Error al obtener la suma de donaciones monetarias por semana: ${response.statusCode}');
    }
  }
}
