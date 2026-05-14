import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_list/providers/auth_provider.dart';
import 'package:sync_list/providers/task_provider.dart';
import 'package:sync_list/service/auth_service.dart';
import 'package:sync_list/service/database_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final activeRoom = ref.watch(activeRoomProvider);

    final userProfileAsync = ref.watch(userProfileProvider);

    final tasksAsync = ref.watch(taskStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('SyncList'),
        actions: [
          // L O G O U T
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              DatabaseService().clearCompletedTasks(activeRoom);
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
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Current Room:\n$activeRoom',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            userProfileAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (profile) {
                final joinedRooms =
                    profile?['joinedRooms'] as List<dynamic>? ?? [];

                return Column(
                  children: [
                    ...joinedRooms.map(
                      (room) => ListTile(
                        title: Text(room),
                        leading: const Icon(Icons.home),
                        selected: room == activeRoom,
                        onTap: () {
                          ref.read(activeRoomProvider.notifier).state = room;
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Create/Join New Room"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    final roomController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Enter Room Name:'),
                      content: TextField(controller: roomController),
                      actions: [
                        TextButton(
                          onPressed: () {
                            final newRoom = roomController.text.trim();

                            ref.read(activeRoomProvider.notifier).state =
                                newRoom;

                            final user = ref.read(authStateProvider).value;

                            if (user != null) {
                              DatabaseService().joinOrCreateRoom(
                                user.uid,
                                newRoom,
                              );
                            }
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

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(hintText: 'Add a Task'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final taskTitle = _taskController.text.trim();
                    if (taskTitle.isEmpty) return;

                    final user = ref.read(authStateProvider).value;

                    if (user != null && user.email != null) {
                      DatabaseService().addTask(
                        taskTitle,
                        activeRoom,
                        user.email!,
                      );
                      _taskController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 28),

            Expanded(
              child: tasksAsync.when(
                error: (err, stack) => Center(child: Text('Error: $err')),
                loading: () => const Center(child: CircularProgressIndicator()),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet in this room'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          DatabaseService().deleteTask(task.id);
                        },
                        child: ListTile(
                          title: Text(task.title), // Type-safe!
                          subtitle: Text(
                            'Added by ${task.creatorEmail}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (newValue) {
                              DatabaseService().toggleTaskState(
                                task.id,
                                task.isCompleted,
                              );
                            },
                          ),
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
