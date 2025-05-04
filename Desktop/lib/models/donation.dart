import 'package:solidarityhub/models/victim.dart';

enum PhysicalDonationType { Other, Food, Tools, Clothes, Medicine, Furniture }

enum Currency { Other, USD, EUR }

enum PaymentStatus { Pending, Completed, Failed, Refunded }

enum PaymentService { Other, PayPal, BankTransfer, CreditCard }

class Volunteer {
  final int id;
  final String name;
  final String surname;

  Volunteer({required this.id, required this.name, required this.surname});

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] ?? 0,
      name: json['volunteer_name'] ?? json['name'] ?? '',
      surname: json['volunteer_surname'] ?? json['surname'] ?? '',
    );
  }
}

class MonetaryDonation {
  final int id;
  final double amount;
  final Currency currency;
  final PaymentStatus paymentStatus;
  final PaymentService paymentService;
  final String transactionId;
  final Victim? assignedVictim;
  final Volunteer? volunteer;
  final DateTime donationDate;

  MonetaryDonation({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    required this.paymentService,
    required this.transactionId,
    this.assignedVictim,
    this.volunteer,
    DateTime? donationDate,
  }) : donationDate = donationDate ?? DateTime.now();

  factory MonetaryDonation.fromJson(Map<String, dynamic> json) {
    return MonetaryDonation(
      id: json['id']?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: _parseCurrency(json['currency']),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      paymentService: _parsePaymentService(json['payment_service']),
      transactionId: json['transaction_id']?.toString() ?? '',
      assignedVictim:
          json['victim_id'] != null
              ? Victim.fromJson({
                'id': json['victim_id'],
                'name': json['victim_name'] ?? '',
                'surname': json['victim_surname'] ?? '',
                'email': json['victim_email'] ?? '',
                'prefix': json['victim_prefix'] ?? 0,
                'phone_number': json['victim_phone_number'] ?? '',
                'address': json['victim_address'] ?? '',
                'identification': json['victim_identification'] ?? '',
                'location_id': json['victim_location_id'] ?? 0,
              })
              : null,
      volunteer:
          (json['volunteer_id'] != null || json['volunteer_name'] != null)
              ? Volunteer(
                id: json['volunteer_id'] ?? 0,
                name: json['volunteer_name'] ?? '',
                surname: json['volunteer_surname'] ?? '',
              )
              : null,
      donationDate: json['donation_date'] != null ? DateTime.parse(json['donation_date']) : DateTime.now(),
    );
  }

  static Currency _parseCurrency(dynamic value) {
    if (value == null) return Currency.Other;
    if (value is int) {
      return Currency.values.firstWhere((type) => type.index == value, orElse: () => Currency.Other);
    } else if (value is String) {
      return Currency.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
        orElse: () => Currency.Other,
      );
    }
    return Currency.Other;
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    if (value == null) return PaymentStatus.Pending;
    if (value is int) {
      return PaymentStatus.values.firstWhere((type) => type.index == value, orElse: () => PaymentStatus.Pending);
    } else if (value is String) {
      return PaymentStatus.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
        orElse: () => PaymentStatus.Pending,
      );
    }
    return PaymentStatus.Pending;
  }

  static PaymentService _parsePaymentService(dynamic value) {
    if (value == null) return PaymentService.Other;
    if (value is int) {
      return PaymentService.values.firstWhere((type) => type.index == value, orElse: () => PaymentService.Other);
    } else if (value is String) {
      return PaymentService.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
        orElse: () => PaymentService.Other,
      );
    }
    return PaymentService.Other;
  }
}

class Donation {
  final int id;
  final String itemName;
  final String description;
  final PhysicalDonationType category;
  final int donated;
  final int distributed;
  final Victim? assignedVictim;
  final Volunteer? volunteer;
  final DateTime donationDate;

  Donation({
    required this.id,
    required this.itemName,
    required this.description,
    required this.category,
    required this.donated,
    this.distributed = 0,
    this.assignedVictim,
    this.volunteer,
    DateTime? donationDate,
  }) : donationDate = donationDate ?? DateTime.now();

  int get availableQuantity => donated - distributed;

  bool get isFullyDistributed => distributed >= donated;

  bool canDistribute(int quantity) {
    return quantity > 0 && quantity <= availableQuantity;
  }

  Donation copyWith({
    int? id,
    String? itemName,
    String? description,
    PhysicalDonationType? category,
    int? donated,
    int? distributed,
    Victim? assignedVictim,
    Volunteer? volunteer,
    DateTime? donationDate,
  }) {
    return Donation(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      category: category ?? this.category,
      donated: donated ?? this.donated,
      distributed: distributed ?? this.distributed,
      assignedVictim: assignedVictim ?? this.assignedVictim,
      volunteer: volunteer ?? this.volunteer,
      donationDate: donationDate ?? this.donationDate,
    );
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    // Asegurar que los campos numéricos tienen valores por defecto
    final int donationId = json['id']?.toInt() ?? 0;
    final int quantity = json['quantity']?.toInt() ?? 0;
    final int distributed = json['distributed']?.toInt() ?? 0;
    final int? victimId = json['victim_id']?.toInt();
    final int? volunteerId = json['volunteer_id']?.toInt();

    return Donation(
      id: donationId,
      itemName: json['item_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _parseDonationType(json['item_type']),
      donated: quantity,
      distributed: distributed,
      assignedVictim:
          victimId != null
              ? Victim.fromJson({
                'id': victimId,
                'name': json['victim_name']?.toString() ?? '',
                'surname': json['victim_surname']?.toString() ?? '',
                'email': json['victim_email']?.toString() ?? '',
                'prefix': json['victim_prefix']?.toInt() ?? 0,
                'phone_number': json['victim_phone_number']?.toString() ?? '',
                'address': json['victim_address']?.toString() ?? '',
                'identification': json['victim_identification']?.toString() ?? '',
                'location_id': json['victim_location_id']?.toInt() ?? 0,
              })
              : null,
      volunteer:
          (volunteerId != null || json['volunteer_name'] != null)
              ? Volunteer(
                id: volunteerId ?? 0,
                name: json['volunteer_name']?.toString() ?? '',
                surname: json['volunteer_surname']?.toString() ?? '',
              )
              : null,
      donationDate: json['donation_date'] != null ? DateTime.parse(json['donation_date']) : DateTime.now(),
    );
  }

  static PhysicalDonationType _parseDonationType(dynamic value) {
    if (value == null) return PhysicalDonationType.Other;

    if (value is int) {
      return PhysicalDonationType.values.firstWhere(
        (type) => type.index == value,
        orElse: () => PhysicalDonationType.Other,
      );
    } else if (value is String) {
      return PhysicalDonationType.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
        orElse: () => PhysicalDonationType.Other,
      );
    }

    return PhysicalDonationType.Other;
  }
}
