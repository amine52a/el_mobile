import 'conversation.dart';

/// Extended conversation model with participant names for UI display
class ConversationWithNames {
  final Conversation conversation;
  final String participant1Name;
  final String participant2Name;

  ConversationWithNames({
    required this.conversation,
    required this.participant1Name,
    required this.participant2Name,
  });

  /// Get the name of the other participant
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == conversation.participant1Id
        ? participant2Name
        : participant1Name;
  }

  /// Get conversation ID
  int? get id => conversation.id;

  /// Get last message
  String? get lastMessage => conversation.lastMessage;

  /// Get last message time
  DateTime? get lastMessageTime => conversation.lastMessageTime;

  /// Get unread count
  int get unreadCount => conversation.unreadCount;

  /// Get the other participant ID
  String getOtherParticipantId(String currentUserId) {
    return conversation.getOtherParticipantId(currentUserId);
  }
}
