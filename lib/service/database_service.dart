import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _taskCollection = FirebaseFirestore.instance
      .collection('tasks');

  // 1. add a new task
  Future<void> addTask(String title) async {
    try {
      await _taskCollection.add({
        'title': title,
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
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
  Stream<QuerySnapshot> get tasksStream {
    return _taskCollection.orderBy('timestamp', descending: true).snapshots();
  }
}
