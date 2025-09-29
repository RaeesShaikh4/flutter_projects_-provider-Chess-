import 'package:flutter/material.dart';
import 'package:flutter_practices/provider_practices/to_do/providers/todo_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<ToDoProvider>(context, listen: false).fetchTodos();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Consumer<ToDoProvider>(
        builder: (context, toDoProvider, child) {
          if (toDoProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (toDoProvider.todos.isEmpty) {
            return Center(child: Text('No todos found'));
          } else {
            return ListView.builder(
              itemCount: toDoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = toDoProvider.todos[index];
                return Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.yellow.shade200,
                  child: Center(
                    child: Text(todo.title ?? ''),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
