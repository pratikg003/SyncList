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
  final TextEditingController _syncCodeController = TextEditingController(text: 'my-secret-room');

  @override
  void dispose() {
    super.dispose();
    _taskController.dispose();
    _syncCodeController.dispose();
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

            // SYNC CODE
            TextField(
              decoration: InputDecoration(hintText: 'Enter room code'),
              controller: _syncCodeController,
            ),

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
                    final syncCode = _syncCodeController.text.trim();
                    DatabaseService().addTask(task, syncCode);
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
                stream: DatabaseService().tasksStream(
                  _syncCodeController.text.trim(),
                ),
                builder: (context, snapshot) {
                  // 1. Handle waiting state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. CATCH THE ERROR (ADD THIS BLOCK)
                  if (snapshot.hasError) {
                    // This prints the exact error (and the magic link!) to your IDE console
                    print("🔥 FIREBASE ERROR: ${snapshot.error}");
                    return const Center(
                      child: Text('An error occurred. Check the console!'),
                    );
                  }

                  // 3. Handle empty lists
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No tasks yet'));
                  }

                  // 4. Build the list
                  final tasks = snapshot.data!.docs;
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
