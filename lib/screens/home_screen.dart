import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_list/providers/task_provider.dart';
import 'package:sync_list/service/auth_service.dart';
import 'package:sync_list/service/database_service.dart';
import 'package:sync_list/widgets/add_task_bottom_sheet.dart';
import 'package:sync_list/widgets/room_drawer.dart';
import 'package:sync_list/widgets/task_list.dart';

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
      drawer: const RoomDrawer(),

      body: const TaskList(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, 
            builder: (context) => const AddTaskBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
