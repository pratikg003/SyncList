import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _taskCollection = FirebaseFirestore.instance
      .collection('tasks');

  // 1. add a new task
  Future<void> addTask(
    String title,
    String syncCode,
    String creatorEmail,
  ) async {
    try {
      await _taskCollection.add({
        'title': title,
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
        'syncCode': syncCode,
        'creatorEmail': creatorEmail,
      });
    } catch (e) {
      print("Failed to add task: $e");
    }
  }

  // 2. Update/toggle task
  Future<void> toggleTaskState(String docId, bool currentState) async {
    try {
      await _taskCollection.doc(docId).update({'isCompleted': !currentState});
    } catch (e) {
      print("Failed to update task: $e");
    }
  }

  // 3. The Live Stream(Data Pipe)
  Stream<QuerySnapshot> tasksStream(String syncCode) {
    return _taskCollection
        .where('syncCode', isEqualTo: syncCode)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 4. Fetch a user's profile data (One-Time Read)
  Future<String?> getLastActiveRoom(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('lastActiveRoom');
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Update a user's active room in their profile
  Future<void> updateActiveRoom(String uid, String newRoom) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastActiveRoom': newRoom,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Fetch a user's list of joined rooms
  Future<List?> getJoinedRooms(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('joinedRooms');
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Add a room to the user's list AND set it as active
  Future<void> joinOrCreateRoom(String uid, String roomName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'joinedRooms': FieldValue.arrayUnion([roomName]),
        'lastActiveRoom': roomName,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error joining room: $e");
    }
  }

  // Delete a specific task
  Future<void> deleteTask(String docId) async {
    try {
      await _taskCollection.doc(docId).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  // Clear all completed tasks in a specific room
  Future<void> clearCompletedTasks(String syncCode) async {
    try {
      var snapshot = await _taskCollection
          .where('syncCode', isEqualTo: syncCode)
          .where('isCompleted', isEqualTo: true)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print("Error clearing tasks: $e");
    }
  }
}
