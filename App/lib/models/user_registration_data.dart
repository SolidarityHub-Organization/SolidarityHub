class UserRegistrationData {
  String? email;
  String? password;
  String? name;
  String? surname;
  String? birthDate;
  String? phone;
  String? role;

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
      'prefix': "34",
      'phone_number': phone,
      'role': role,
      'address': "calle",
      'identification':2,
      /*{
        'line1': addressLine1,
        'line2': addressLine2,
        'country': country,
        'province': province,
        'city': city,
        'postal_code': postalCode,
      }*/
    };
  }
}

