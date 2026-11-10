import 'package:flutter/foundation.dart';
import '../data/models/conversation.dart';
import '../data/models/conversation_with_names.dart';
import '../data/models/message.dart';
import '../services/messaging_service.dart';

/// Provider for messaging state management - Module 4
class MessagingProvider with ChangeNotifier {
  final MessagingService _service = MessagingService();

  // State
  List<Conversation> _conversations = [];
  List<ConversationWithNames> _conversationsWithNames = [];
  Conversation? _currentConversation;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _totalUnreadCount = 0;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<ConversationWithNames> get conversationsWithNames => _conversationsWithNames;
  Conversation? get currentConversation => _currentConversation;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnreadCount => _totalUnreadCount;

  // ==================== CONVERSATIONS ====================

  /// Load all conversations for a user
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _service.getUserConversations(userId);
      _conversationsWithNames = await _service.getUserConversationsWithNames(userId);
      _totalUnreadCount = await _service.getTotalUnreadCount(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des conversations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start or get existing conversation
  Future<int?> startConversation(String user1Id, String user2Id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversationId = await _service.startConversation(user1Id, user2Id);
      _isLoading = false;
      notifyListeners();
      return conversationId;
    } catch (e) {
      _error = 'Erreur lors de la création de la conversation: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Load a specific conversation
  Future<void> loadConversation(int conversationId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversation = await _service.getConversationById(conversationId);
      if (_currentConversation != null) {
        await loadMessages(conversationId);
        // Mark messages as read
        await _service.markConversationAsRead(conversationId, userId);
        // Refresh total unread count
        _totalUnreadCount = await _service.getTotalUnreadCount(userId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement de la conversation: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a conversation
  Future<bool> deleteConversation(int conversationId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteConversation(conversationId);
      if (success) {
        _conversations.removeWhere((c) => c.id == conversationId);
        _totalUnreadCount = await _service.getTotalUnreadCount(userId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== MESSAGES ====================

  /// Load messages for a conversation
  Future<void> loadMessages(int conversationId) async {
    try {
      _messages = await _service.getConversationMessages(conversationId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des messages: $e';
      notifyListeners();
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required int conversationId,
    required String senderId,
    required String content,
    String? senderName,
  }) async {
    if (content.trim().isEmpty) return false;

    try {
      final messageId = await _service.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
      );

      if (messageId > 0) {
        // Reload messages to get the new one
        await loadMessages(conversationId);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de l\'envoi du message: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark message as read
  Future<void> markAsRead(int messageId) async {
    try {
      await _service.markMessageAsRead(messageId);
      // Update local state
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du marquage: $e';
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(int messageId, int conversationId) async {
    try {
      final success = await _service.deleteMessage(messageId);
      if (success) {
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search messages in current conversation
  Future<void> searchMessages(int conversationId, String query) async {
    try {
      _messages = await _service.searchMessages(conversationId, query);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      notifyListeners();
    }
  }

  // ==================== UTILITY ====================

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh conversations (call after sending message)
  Future<void> refreshConversations(String userId) async {
    try {
      _conversations = await _service.getUserConversations(userId);
      _totalUnreadCount = await _service.getTotalUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      // Silent fail for refresh
    }
  }

  /// Get unread count for specific conversation
  int getUnreadCount(int conversationId) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => Conversation(
        participant1Id: '',
        participant2Id: '',
      ),
    );
    return conversation.unreadCount;
  }
}
