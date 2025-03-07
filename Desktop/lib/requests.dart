import 'dart:convert';
import 'package:http/http.dart' as http;

class Requests {
  Future<String> fetchTest() async {
    final url = Uri.parse("https://localhost:7138/api/v1/get-example-data");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData.toString();
      } else {
        return "Error requesting the endpoint: ${response.statusCode}";
      }
    } catch (error) {
      return "Error: $error";
    }
  }

  Future<String> addUser() async {
    final url = Uri.parse("https://localhost:7138/api/v1/insert-user-test");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return "User has been added";
      } else {
        return "Error requesting the endpoint: ${response.statusCode}";
      }
    } catch (error) {
      return "Error: $error";
    }
  }

  Future<String> getUsers() async {
    final url = Uri.parse("https://localhost:7138/api/v1/get-users-test");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = json.decode(response.body);
        return jsonData.toString();
      } else {
        return "Error requesting the endpoint: ${response.statusCode}";
      }
    } catch (error) {
      return "Error: $error";
    }
  }
}
