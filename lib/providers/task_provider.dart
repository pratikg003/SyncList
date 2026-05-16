import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sync_list/models/task_model.dart';
import 'auth_provider.dart';

final activeRoomProvider = StateProvider<String>((ref) => 'general');

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data());
});

final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final currentRoom = ref.watch(activeRoomProvider);

  return FirebaseFirestore.instance
      .collection('tasks')
      .where('syncCode', isEqualTo: currentRoom)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshots) {
        return snapshots.docs.map((doc) {
          return TaskModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
});
