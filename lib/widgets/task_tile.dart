import 'package:flutter/material.dart';
import 'package:sync_list/models/task_model.dart';
import 'package:sync_list/service/database_service.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
            DatabaseService().toggleTaskState(task.id, task.isCompleted);
          },
        ),
      ),
    );
  }
}
