import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final String syncCode;
  final String creatorEmail;
  final DateTime? timestamp;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.syncCode,
    required this.creatorEmail,
    required this.timestamp,
  });

  factory TaskModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return TaskModel(
      id: documentId,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      syncCode: data['syncCode'] ?? '',
      creatorEmail: data['creatorEmail'] ?? 'Unknown',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map <String, dynamic> toMap() {
    return {
      'title' : title,
      'isCompleted': isCompleted,
      'syncCode' : syncCode,
      'creatorEmail': creatorEmail,
      'timestamp': timestamp
    };
  }
}
