import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String adminId;
  final String adminName;
  final String contentType; // 'text', 'image', 'video', 'audio', 'file'
  final String content;
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime createdAt;
  final Map<String, int> reactions; // emoji -> count
  final int viewCount;

  PostModel({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.contentType,
    required this.content,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    required this.createdAt,
    Map<String, int>? reactions,
    this.viewCount = 0,
  }) : reactions = reactions ?? {};

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      contentType: map['contentType'] ?? 'text',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      createdAt: _parseDateTime(map['createdAt']),
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      viewCount: map['viewCount'] ?? 0,
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
      'adminId': adminId,
      'adminName': adminName,
      'contentType': contentType,
      'content': content,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'reactions': reactions,
      'viewCount': viewCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? adminId,
    String? adminName,
    String? contentType,
    String? content,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    DateTime? createdAt,
    Map<String, int>? reactions,
    int? viewCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  int getTotalReactions() {
    return reactions.values.fold(0, (sum, count) => sum + count);
  }
}