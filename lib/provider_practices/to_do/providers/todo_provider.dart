import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_practices/provider_practices/to_do/model/to_do.dart';
import 'package:http/http.dart' as http;

class ToDoProvider extends ChangeNotifier {
  List<ToDo> _todos = [];
  bool _isLoading = false;

  List<ToDo> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> fetchTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _todos = data.map((json) => ToDo.fromJson(json)).toList();
      } else {
        print('[api-todo] Error fetching todos response: ${response.body}');
      }
    } catch (e) {
      print('[api-todo] catch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
