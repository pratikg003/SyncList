import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _taskCollection = FirebaseFirestore.instance
      .collection('tasks');

  // 1. add a new task
  Future<void> addTask(String title, String syncCode) async {
    try {
      await _taskCollection.add({
        'title': title,
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
        'syncCode': syncCode,
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
}
