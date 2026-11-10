/// Conversation model for messaging - Module 4
class Conversation {
  final int? id;
  final String participant1Id; // UUID
  final String participant2Id; // UUID
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;

  Conversation({
    this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Conversation to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant1Id': participant1Id,
      'participant2Id': participant2Id,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Conversation from Map
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as int?,
      participant1Id: map['participant1Id'] as String,
      participant2Id: map['participant2Id'] as String,
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'] as String)
          : null,
      unreadCount: map['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy with updated fields
  Conversation copyWith({
    int? id,
    String? participant1Id,
    String? participant2Id,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get the other participant ID (for displaying conversation partner)
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == participant1Id ? participant2Id : participant1Id;
  }

  /// Get formatted time for last message
  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }
}
