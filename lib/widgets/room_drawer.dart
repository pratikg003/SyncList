import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_list/service/database_service.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';

class RoomDrawer extends ConsumerWidget {
  const RoomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRoom = ref.watch(activeRoomProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              'Current Room:\n$activeRoom',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // The joinedRooms List
          userProfileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading rooms: $err'),
            ),
            data: (profile) {
              final joinedRooms =
                  profile?['joinedRooms'] as List<dynamic>? ?? [];

              if (joinedRooms.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No saved rooms yet.'),
                );
              }

              return Column(
                children: joinedRooms
                    .map(
                      (room) => ListTile(
                        title: Text(room.toString()),
                        leading: const Icon(Icons.meeting_room),
                        selected: room == activeRoom,
                        onTap: () {
                          ref.read(activeRoomProvider.notifier).state = room
                              .toString();
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),

          const Divider(),

          // Create / Join Button
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create / Join New Room'),
            onTap: () {
              Navigator.pop(context);
              _showAddRoomDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final roomController = TextEditingController();
        
        return Consumer(
          builder: (context, ref, child) {
            return AlertDialog(
              title: const Text('Enter Room Name'),
              content: TextField(
                controller: roomController,
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final newRoom = roomController.text.trim();
                    if (newRoom.isNotEmpty) {
                      // This 'ref' is alive and safe to use!
                      ref.read(activeRoomProvider.notifier).state = newRoom;
                      final user = ref.read(authStateProvider).value;
                      if (user != null) {
                        DatabaseService().joinOrCreateRoom(user.uid, newRoom);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Go'),
                )
              ],
            );
          }
        );
      }
    );
  }
}
