import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_list/providers/task_provider.dart';
import 'package:sync_list/service/database_service.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';

class TaskTile extends ConsumerWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final String? currentEmail = currentUser?.email;

    final bool canDelete = task.creatorEmail == currentEmail;
    final String? assignee = task.assignedTo;

    final bool canComplete =
        assignee == null ||
        assignee.trim().isEmpty ||
        assignee == currentEmail ||
        task.creatorEmail == currentEmail;
    final bool canAssign = task.creatorEmail == currentEmail;

    return Dismissible(
      key: Key(task.id),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none,
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
        title: Text(task.title),
        subtitle: Text(
          task.assignedTo != null
              ? 'Assigned to: ${task.assignedTo}'
              : 'Added by: ${task.creatorEmail}',
          style: const TextStyle(fontSize: 12),
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: canComplete
              ? (newValue) {
                  if (currentEmail != null) {
                    DatabaseService().toggleTaskState(
                      task.id,
                      task.isCompleted,
                      currentEmail,
                    );
                  }
                }
              : null,
        ),
        trailing: canAssign
            ? IconButton(
                icon: const Icon(Icons.person_add_alt_1),
                onPressed: () {
                  _showAssignDialog(context, task.id);
                },
              )
            : null,
      ),
    );
  }

  void _showAssignDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final membersAsync = ref.watch(roomMembersProvider);

            return AlertDialog(
              title: const Text('Assign Task'),
              content: SizedBox(
                width: double.maxFinite,
                child: membersAsync.when(
                  loading: () => const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Text('Error: $err'),
                  data: (members) {
                    if (members.isEmpty) {
                      return const Text('No one else is in this room yet!');
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final memberEmail = members[index];
                        final isCurrentlyAssigned =
                            task.assignedTo == memberEmail;

                        return ListTile(
                          title: Text(memberEmail),
                          tileColor: isCurrentlyAssigned
                              ? Colors.blue.withValues(alpha: 0.1)
                              : null,
                          trailing: isCurrentlyAssigned
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                )
                              : null,
                          onTap: () {
                            final newAssignee = isCurrentlyAssigned
                                ? null
                                : memberEmail;

                            DatabaseService().assignTask(taskId, newAssignee);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
