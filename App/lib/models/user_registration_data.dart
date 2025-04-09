class UserRegistrationData {
  // Datos de login
  String? email;
  String? password;

  // Datos personales
  String? name;
  String? surname;
  String? birthDate;
  String? phone;
  String? role;

  // Dirección
  String? addressLine1;
  String? addressLine2;
  String? country;
  String? province;
  String? city;
  String? postalCode;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'surname': surname,
      'birth_date': birthDate,
      'phone': phone,
      'role': role,
      'address': {
        'line1': addressLine1,
        'line2': addressLine2,
        'country': country,
        'province': province,
        'city': city,
        'postal_code': postalCode,
      }
    };
  }
}