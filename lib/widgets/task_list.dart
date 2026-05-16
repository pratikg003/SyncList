import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_tile.dart';
import '../providers/task_provider.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Error: $error")),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet in this room'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskTile(task: tasks[index]);
          },
        );
      },
    );
  }
}
