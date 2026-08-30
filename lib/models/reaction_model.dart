class ReactionModel {
  final String id;
  final String postId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory ReactionModel.fromMap(Map<String, dynamic> map, String id) {
    return ReactionModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      emoji: map['emoji'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReactionModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? emoji,
    DateTime? createdAt,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}