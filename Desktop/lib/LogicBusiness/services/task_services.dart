import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl;

  TaskService(this.baseUrl);

  Future<String> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode == 200) {
      return "Task deleted successfully";
    } else {
      throw Exception('Failed to delete task with id $id');
    }
  }
}
