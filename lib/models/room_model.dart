import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name;
  final DateTime createdAt;

  RoomModel({required this.id, required this.name, required this.createdAt});

  factory RoomModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RoomModel(
      id: documentId,
      name: data['name'] ?? 'Unknown Room',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'createdAt': Timestamp.fromDate(createdAt)};
  }
}
