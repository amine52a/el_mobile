import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/conversation.dart';
import '../models/conversation_with_names.dart';
import '../models/message.dart';
import '../../core/constants/app_constants.dart';

/// Repository for messaging operations - Module 4
class MessagingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CONVERSATIONS ====================

  /// Get all conversations for a user
  Future<List<Conversation>> getUserConversations(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableConversations,
      where: 'participant1Id = ? OR participant2Id = ?',
      whereArgs: [userId, userId],
      orderBy: 'lastMessageTime DESC',
    );
    return maps.map((map) => Conversation.fromMap(map)).toList();
  }

  /// Get all conversations for a user with participant names
  Future<List<ConversationWithNames>> getUserConversationsWithNames(String userId) async {
    final db = await _dbHelper.database;
    
    // Join conversations with users table to get participant names
    final query = '''
      SELECT 
        c.*,
        (u1.firstName || ' ' || u1.lastName) as participant1Name,
        (u2.firstName || ' ' || u2.lastName) as participant2Name
      FROM ${AppConstants.tableConversations} c
      LEFT JOIN ${AppConstants.usersTable} u1 ON c.participant1Id = u1.id
      LEFT JOIN ${AppConstants.usersTable} u2 ON c.participant2Id = u2.id
      WHERE c.participant1Id = ? OR c.participant2Id = ?
      ORDER BY c.lastMessageTime DESC
    ''';
    
    final maps = await db.rawQuery(query, [userId, userId]);
    
    return maps.map((map) {
      return ConversationWithNames(
        conversation: Conversation.fromMap(map),
        participant1Name: map['participant1Name'] as String? ?? 'Utilisateur',
        participant2Name: map['participant2Name'] as String? ?? 'Utilisateur',
      );
    }).toList();
  }

  /// Get a specific conversation by ID
  Future<Conversation?> getConversationById(int conversationId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableConversations,
      where: 'id = ?',
      whereArgs: [conversationId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }

  /// Get or create a conversation between two users
  Future<int> getOrCreateConversation(
      String user1Id, String user2Id) async {
    final db = await _dbHelper.database;
    
    // Try to find existing conversation
    final maps = await db.query(
      AppConstants.tableConversations,
      where: '(participant1Id = ? AND participant2Id = ?) OR (participant1Id = ? AND participant2Id = ?)',
      whereArgs: [user1Id, user2Id, user2Id, user1Id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }
    
    // Create new conversation
    final conversation = Conversation(
      participant1Id: user1Id,
      participant2Id: user2Id,
    );
    
    return await db.insert(
      AppConstants.tableConversations,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update conversation's last message
  Future<void> updateLastMessage(
      int conversationId, String message, DateTime time) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableConversations,
      {
        'lastMessage': message,
        'lastMessageTime': time.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Increment unread count for a conversation
  Future<void> incrementUnreadCount(int conversationId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableConversations} SET unreadCount = unreadCount + 1 WHERE id = ?',
      [conversationId],
    );
  }

  /// Reset unread count for a conversation
  Future<void> resetUnreadCount(int conversationId) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableConversations,
      {'unreadCount': 0},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Delete a conversation
  Future<int> deleteConversation(int conversationId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableConversations,
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // ==================== MESSAGES ====================

  /// Get all messages in a conversation
  Future<List<Message>> getConversationMessages(int conversationId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMessages,
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  /// Get unread messages for a user in a conversation
  Future<List<Message>> getUnreadMessages(
      int conversationId, String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMessages,
      where: 'conversationId = ? AND receiverId = ? AND isRead = 0',
      whereArgs: [conversationId, userId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  /// Create a new message
  Future<int> createMessage(Message message) async {
    final db = await _dbHelper.database;
    
    final messageId = await db.insert(
      AppConstants.tableMessages,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update conversation's last message
    await updateLastMessage(
      message.conversationId,
      message.content,
      message.createdAt,
    );
    
    // Increment unread count
    await incrementUnreadCount(message.conversationId);
    
    return messageId;
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(int messageId) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMessages,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Mark all messages in a conversation as read for a user
  Future<void> markAllMessagesAsRead(
      int conversationId, String userId) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMessages,
      {'isRead': 1},
      where: 'conversationId = ? AND receiverId = ?',
      whereArgs: [conversationId, userId],
    );
    
    // Reset unread count
    await resetUnreadCount(conversationId);
  }

  /// Delete a message
  Future<int> deleteMessage(int messageId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableMessages,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Delete all messages in a conversation
  Future<int> deleteConversationMessages(int conversationId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableMessages,
      where: 'conversationId = ?',
      whereArgs: [conversationId],
    );
  }
}
