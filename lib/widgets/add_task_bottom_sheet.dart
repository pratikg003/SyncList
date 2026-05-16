import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_list/service/database_service.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final taskTitle = _taskController.text.trim();
    if (taskTitle.isEmpty) return;

    final activeRoom = ref.read(activeRoomProvider);
    final user = ref.read(authStateProvider).value;

    if (user != null && user.email != null) {
      DatabaseService().addTask(taskTitle, activeRoom, user.email!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                  ),
                  onSubmitted: (_) => _submitTask(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _submitTask, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
