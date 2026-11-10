/// Forum post model for Module 4 - Community & Mentorship
class ForumPost {
  final int? id;
  final String authorId; // UUID
  final String authorName;
  final int courseId;
  final int? chapterId; // null = course-level post
  final String title;
  final String content;
  final List<String> tags; // For filtering and search
  final int likesCount;
  final int commentsCount;
  final bool isPinned; // Pinned posts appear first
  final bool isSolved; // For Q&A posts
  final DateTime createdAt;
  final DateTime? updatedAt;

  ForumPost({
    this.id,
    required this.authorId,
    required this.authorName,
    required this.courseId,
    this.chapterId,
    required this.title,
    required this.content,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPinned = false,
    this.isSolved = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert ForumPost to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'content': content,
      'tags': tags.join(','),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isPinned': isPinned ? 1 : 0,
      'isSolved': isSolved ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create ForumPost from Map
  factory ForumPost.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String?;
    final tags = tagsStr != null && tagsStr.isNotEmpty
        ? tagsStr.split(',')
        : <String>[];

    return ForumPost(
      id: map['id'] as int?,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      courseId: map['courseId'] as int,
      chapterId: map['chapterId'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: tags,
      likesCount: map['likesCount'] as int? ?? 0,
      commentsCount: map['commentsCount'] as int? ?? 0,
      isPinned: (map['isPinned'] as int?) == 1,
      isSolved: (map['isSolved'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  ForumPost copyWith({
    int? id,
    String? authorId,
    String? authorName,
    int? courseId,
    int? chapterId,
    String? title,
    String? content,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    bool? isPinned,
    bool? isSolved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPinned: isPinned ?? this.isPinned,
      isSolved: isSolved ?? this.isSolved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} an${(difference.inDays / 365).floor() > 1 ? "s" : ""}';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? "s" : ""}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""}';
    } else {
      return 'À l\'instant';
    }
  }
}
