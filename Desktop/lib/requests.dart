import 'dart:convert';
import 'package:http/http.dart' as http;

class Requests {
  Future<String> fetchTest() async {
    final url = Uri.parse(
      "http://localhost:5170/api/WeatherForecast/get-forecast",
    );

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
    final url = Uri.parse("http://localhost:5170/api/v1/users");

    try {
      final response = await http.post(
        url,
        headers: {
          // The header defines the type of data being sent.
          'Content-Type': 'application/json',
        },
        body: json.encode({"name": "John Doe", "email": "jondoe@example.com"}),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return "User has been added";
      } else {
        return "Error requesting the endpoint: ${response.statusCode}";
      }
    } catch (error) {
      return "Error: $error";
    }
  }

  Future<String> getUsers() async {
    final url = Uri.parse("http://localhost:5170/api/v1/users");

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
