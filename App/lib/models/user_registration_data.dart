class UserRegistrationData {
  String? email;
  String? password;
  String? name;
  String? surname;
  String? birthDate;
  String? phone;
  String? role;
  String? address;
  String? schedule;
  String? preferences;
  String? needs;
  String? identification;

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
      'address': address,
      'identification': identification
    };
  }

  Map<String, dynamic> volunteerToJson() {
    return {
      'schedule': schedule,
      'preferences': preferences
    };
  }

  Map<String, dynamic> victimToJson() {
    return {
      'needs': needs
    };
  }

  Map<String, dynamic> emailValidation() {
    return {
      'email': email,
      'password': null,
    };
  }

}

