import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(
        title: Text('SyncList'),
        actions: [
          IconButton(onPressed: authService.logOut, icon: Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGIN TEXT
            const Text('You are successfully logged in!'),
            const SizedBox(height: 28),

            // ADD A TASK
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Add a task'),
                    controller: _taskController,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final task = _taskController.text.trim();
                    DatabaseService().addTask(task);
                    _taskController.clear();
                  },
                  child: Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            //  BUILDING THE LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: DatabaseService().tasksStream,
                builder: (context, snapshot) {
                  // 1. handle waiting state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Handle empty lists
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No tasks yet'));
                  }

                  // 3. Extract the list of documents
                  final tasks = snapshot.data!.docs;

                  // 4. Build the list
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var taskDoc = tasks[index];

                      String title = taskDoc['title'];
                      bool isCompleted = taskDoc['isCompleted'];
                      String docId = taskDoc.id;

                      return ListTile(
                        title: Text(title),
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: (newValue) {
                            // Call the toggle function you wrote on Day 5!
                            DatabaseService().toggleTaskState(
                              docId,
                              isCompleted,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
