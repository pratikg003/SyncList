import 'package:flutter/material.dart';
import 'package:sync_list/service/auth_service.dart';
import 'package:sync_list/service/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text('SyncList')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGIN TEXT
              const Text('You are successfully logged in!'),
              const SizedBox(height: 28),

              // ADD A TASK
              TextField(
                decoration: InputDecoration(hintText: 'Add a task'),
                controller: _taskController,
              ),
              ElevatedButton(
                onPressed: () {
                  final task = _taskController.text.trim();
                  DatabaseService().addTask(task);
                  _taskController.clear();
                },
                child: Text('Add'),
              ),
              const SizedBox(height: 28),

              // LOGOUT
              ElevatedButton(
                onPressed: authService.logOut,
                child: Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
