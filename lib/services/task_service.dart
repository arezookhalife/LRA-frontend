import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/task_model.dart';

class TaskService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<TaskModel>> getTasks() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(ApiConstants.tasksUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.tasksUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return TaskModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create task:  ${response.body}');
    }
  }
}
