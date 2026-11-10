/// Like model for forum posts and comments - Module 4
class ForumLike {
  final int? id;
  final String userId; // UUID
  final int? postId; // null if liking a comment
  final int? commentId; // null if liking a post
  final DateTime createdAt;

  ForumLike({
    this.id,
    required this.userId,
    this.postId,
    this.commentId,
    DateTime? createdAt,
  })  : assert(postId != null || commentId != null,
            'Either postId or commentId must be provided'),
        createdAt = createdAt ?? DateTime.now();

  /// Convert ForumLike to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create ForumLike from Map
  factory ForumLike.fromMap(Map<String, dynamic> map) {
    return ForumLike(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      postId: map['postId'] as int?,
      commentId: map['commentId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy with updated fields
  ForumLike copyWith({
    int? id,
    String? userId,
    int? postId,
    int? commentId,
    DateTime? createdAt,
  }) {
    return ForumLike(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
