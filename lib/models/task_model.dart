import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final String syncCode;
  final String creatorEmail;
  final DateTime? timestamp;

  final String? assignedTo;
  final String? completedBy;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.syncCode,
    required this.creatorEmail,
    required this.timestamp,
    this.assignedTo,
    this.completedBy,
    this.completedAt,
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

      assignedTo: data['assignedTo'],
      completedBy: data['completedBy'],
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'syncCode': syncCode,
      'creatorEmail': creatorEmail,
      'timestamp': timestamp,

      'assignedTo': assignedTo,
      'completedBy': completedBy,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}
