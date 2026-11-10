import '../data/models/conversation.dart';
import '../data/models/conversation_with_names.dart';
import '../data/models/message.dart';
import '../data/repositories/messaging_repository.dart';

/// Service for managing messaging-related business logic - Module 4
class MessagingService {
  final MessagingRepository _repository = MessagingRepository();

  // ==================== CONVERSATIONS METHODS ====================

  /// Get all conversations for a user
  Future<List<Conversation>> getUserConversations(String userId) async {
    return await _repository.getUserConversations(userId);
  }

  /// Get all conversations for a user with participant names
  Future<List<ConversationWithNames>> getUserConversationsWithNames(String userId) async {
    return await _repository.getUserConversationsWithNames(userId);
  }

  /// Get a specific conversation by ID
  Future<Conversation?> getConversationById(int conversationId) async {
    return await _repository.getConversationById(conversationId);
  }

  /// Start a new conversation or get existing one
  Future<int> startConversation(String user1Id, String user2Id) async {
    return await _repository.getOrCreateConversation(user1Id, user2Id);
  }

  /// Delete a conversation and all its messages
  Future<bool> deleteConversation(int conversationId) async {
    // Delete all messages first
    await _repository.deleteConversationMessages(conversationId);
    
    // Then delete conversation
    final result = await _repository.deleteConversation(conversationId);
    return result > 0;
  }

  /// Get total unread messages count for a user
  Future<int> getTotalUnreadCount(String userId) async {
    final conversations = await getUserConversations(userId);
    int total = 0;
    
    for (var conversation in conversations) {
      total += conversation.unreadCount;
    }
    
    return total;
  }

  // ==================== MESSAGES METHODS ====================

  /// Get all messages in a conversation
  Future<List<Message>> getConversationMessages(int conversationId) async {
    return await _repository.getConversationMessages(conversationId);
  }

  /// Get unread messages for a user in a conversation
  Future<List<Message>> getUnreadMessages(
      int conversationId, String userId) async {
    return await _repository.getUnreadMessages(conversationId, userId);
  }

  /// Send a new message
  Future<int> sendMessage({
    required int conversationId,
    required String senderId,
    required String content,
  }) async {
    final message = Message(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
    );

    return await _repository.createMessage(message);
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(int messageId) async {
    await _repository.markMessageAsRead(messageId);
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead(
      int conversationId, String userId) async {
    await _repository.markAllMessagesAsRead(conversationId, userId);
  }

  /// Delete a message
  Future<bool> deleteMessage(int messageId) async {
    final result = await _repository.deleteMessage(messageId);
    return result > 0;
  }

  // ==================== UTILITY METHODS ====================

  /// Get conversation statistics
  Future<Map<String, int>> getConversationStats(int conversationId) async {
    final messages = await getConversationMessages(conversationId);
    
    return {
      'totalMessages': messages.length,
      'unreadMessages': messages.where((m) => !m.isRead).length,
    };
  }

  /// Search messages in a conversation
  Future<List<Message>> searchMessages(
      int conversationId, String query) async {
    final allMessages = await getConversationMessages(conversationId);
    
    if (query.trim().isEmpty) {
      return allMessages;
    }
    
    return allMessages.where((message) =>
      message.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Get recent messages (last N messages)
  Future<List<Message>> getRecentMessages(
      int conversationId, int limit) async {
    final allMessages = await getConversationMessages(conversationId);
    
    // Return last N messages
    if (allMessages.length <= limit) {
      return allMessages;
    }
    
    return allMessages.sublist(allMessages.length - limit);
  }
}
