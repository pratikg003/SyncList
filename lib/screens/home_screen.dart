import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_list/service/auth_service.dart';
import 'package:sync_list/service/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  String? activeRoom;
  List? joinedRooms;
  bool isLoading = true;

  Future<void> _fetchUserProfile() async {
    final user = Provider.of<User?>(context, listen: false);

    if (user != null) {
      String? room = await DatabaseService().getLastActiveRoom(user.uid);
      List? roomsList = await DatabaseService().getJoinedRooms(user.uid);

      setState(() {
        activeRoom = room ?? 'general';
        joinedRooms = roomsList;
        isLoading = false;
      });
    }
  }

  void _switchRoom(String newRoom) {
    setState(() {
      activeRoom = newRoom;
    });
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      DatabaseService().updateActiveRoom(user.uid, newRoom);
    }
  }

  void _addNewRoom(String newRoom) {
    // 1. Update local UI
    setState(() {
      activeRoom = newRoom;
      if (joinedRooms != null && !joinedRooms!.contains(newRoom)) {
        joinedRooms!.add(newRoom);
      }
    });

    // 2. Update Firebase
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      DatabaseService().joinOrCreateRoom(user.uid, newRoom);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

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
          // L O G O U T
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (activeRoom != null) {
                DatabaseService().clearCompletedTasks(activeRoom!);
              }
            },
          ),

          // Batch delete
          IconButton(onPressed: authService.logOut, icon: Icon(Icons.logout)),
        ],
      ),

      // D R A W E R
      drawer: Drawer(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Joined Rooms:',
                style: TextStyle(color: Colors.blue, fontSize: 24),
              ),
            ),

            if (joinedRooms != null && joinedRooms!.isNotEmpty)
              ...joinedRooms!.map(
                (room) => ListTile(
                  title: Text(room),
                  leading: const Icon(Icons.house_outlined),
                  selected: room == activeRoom,
                  onTap: () {
                    _switchRoom(room);
                    Navigator.pop(context);
                  },
                ),
              ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Join/Create Room'),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController roomController =
                        TextEditingController();
                    return AlertDialog(
                      title: Text('Enter Room Name:'),
                      content: TextField(controller: roomController),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Grab the text, switch the room, and close the dialog
                            if (roomController.text.isEmpty) return;
                            _addNewRoom(roomController.text.trim());
                            Navigator.pop(context);
                          },
                          child: const Text('Go'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGIN TEXT
                  // const Text('You are successfully logged in!'),
                  // const SizedBox(height: 28),

                  // // SYNC CODE
                  // TextField(
                  //   decoration: InputDecoration(hintText: 'Enter room code'),
                  // ),
                  // const SizedBox(height: 28),

                  //  BUILDING THE LIST
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: DatabaseService().tasksStream(activeRoom!),
                      builder: (context, snapshot) {
                        // 1. Handle waiting state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // 2. CATCH THE ERROR
                        if (snapshot.hasError) {
                          print("FIREBASE ERROR: ${snapshot.error}");
                          return const Center(
                            child: Text(
                              'An error occurred. Check the console!',
                            ),
                          );
                        }

                        // 3. Handle empty lists
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No tasks yet'));
                        }

                        // 4. Build the list
                        final tasks = snapshot.data!.docs;

                        final bool isOffline =
                            snapshot.data!.metadata.isFromCache;

                        return Column(
                          children: [
                            // Show a little orange banner if we are reading from the local cache
                            if (isOffline)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '⚡ Working Offline - Changes will sync later',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            Expanded(
                              child: ListView.builder(
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  var taskDoc = tasks[index];

                                  String title = taskDoc['title'];
                                  bool isCompleted = taskDoc['isCompleted'];
                                  String docId = taskDoc.id;

                                  String creatorEmail =
                                      taskDoc['creatorEmail'] ?? 'Unknown User';

                                  return Dismissible(
                                    key: Key(docId),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                        right: 20.0,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),

                                    onDismissed: (direction) {
                                      DatabaseService().deleteTask(docId);
                                    },

                                    child: ListTile(
                                      title: Text(title),
                                      subtitle: Text("Added by: $creatorEmail"),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
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
                          if (task.isEmpty) return;

                          final user = Provider.of<User?>(
                            context,
                            listen: false,
                          );
                          if (user != null && user.email != null) {
                            DatabaseService().addTask(
                              task,
                              activeRoom!,
                              user.email!,
                            );
                            _taskController.clear();
                          }
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
