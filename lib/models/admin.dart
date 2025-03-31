import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String username;
  final String name;
  final DateTime createdAt;

  Admin({
    required this.id,
    required this.username,
    required this.name,
    required this.createdAt,
  });

  // Create Admin from Firestore data
  factory Admin.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Admin(
      id: documentId,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}
