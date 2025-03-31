import 'package:cloud_firestore/cloud_firestore.dart';

class Proxy {
  final String id;
  final String ip;
  final String port;
  final String username;
  final String password;
  final String countryCode;
  final String location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Proxy({
    this.id = '',
    required this.ip,
    required this.port,
    required this.username,
    required this.password,
    required this.countryCode,
    required this.location,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  // Create Proxy from Firestore data
  factory Proxy.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Proxy(
      id: documentId,
      ip: data['ip'] ?? '',
      port: data['port'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      countryCode: data['countryCode'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Convert Proxy to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'ip': ip,
      'port': port,
      'username': username,
      'password': password,
      'countryCode': countryCode,
      'location': location,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Get masked IP for display in list
  String get maskedIp {
    final parts = ip.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.x.x';
    }
    return ip;
  }
}
