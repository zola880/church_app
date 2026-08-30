import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String phoneNumber;
  final String role; // 'admin' or 'member'
  final DateTime createdAt;
  final String? fcmToken;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.fcmToken,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'member',
      createdAt: _parseDateTime(map['createdAt']),
      fcmToken: map['fcmToken'],
      isActive: map['isActive'] ?? true,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Handle Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
    String? fcmToken,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
    );
  }
}