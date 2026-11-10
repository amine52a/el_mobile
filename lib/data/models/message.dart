/// Message model for conversations - Module 4
class Message {
  final int? id;
  final int conversationId;
  final String senderId; // UUID
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Message to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Message from Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      conversationId: map['conversationId'] as int,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      isRead: (map['isRead'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy with updated fields
  Message copyWith({
    int? id,
    int? conversationId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted time
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
