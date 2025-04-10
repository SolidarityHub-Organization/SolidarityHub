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
      'identification': null,
      'schedule':schedule,
      'skill':preferences,
      'needs': needs,
    };
  }
}

