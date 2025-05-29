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
  int? prefix;
  String? identification;

  UserRegistrationData();

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
  factory UserRegistrationData.clone(UserRegistrationData original) {
    return UserRegistrationData()
      ..email = original.email
      ..password = original.password
      ..name = original.name
      ..surname = original.surname
      ..birthDate = original.birthDate
      ..phone = original.phone
      ..role = original.role
      ..address = original.address
      ..schedule = original.schedule
      ..preferences = original.preferences
      ..needs = original.needs
      ..prefix = original.prefix
      ..identification = original.identification;
  }
}
