/// Comment model for forum posts - Module 4
class ForumComment {
  final int? id;
  final int postId;
  final String authorId; // UUID
  final String authorName;

  final String content;
  final int likesCount;
  final bool isAccepted; // For Q&A posts - marks the accepted answer
  final DateTime createdAt;
  final DateTime? updatedAt;

  ForumComment({
    this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,

    required this.content,
    this.likesCount = 0,
    this.isAccepted = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert ForumComment to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,

      'content': content,
      'likesCount': likesCount,
      'isAccepted': isAccepted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create ForumComment from Map
  factory ForumComment.fromMap(Map<String, dynamic> map) {
    return ForumComment(
      id: map['id'] as int?,
      postId: map['postId'] as int,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,

      content: map['content'] as String,
      likesCount: map['likesCount'] as int? ?? 0,
      isAccepted: (map['isAccepted'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  ForumComment copyWith({
    int? id,
    int? postId,
    String? authorId,
    String? authorName,

    String? content,
    int? likesCount,
    bool? isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,

      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}

