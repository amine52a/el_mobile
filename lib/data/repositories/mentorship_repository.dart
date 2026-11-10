import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/mentor_profile.dart';
import '../models/mentorship_request.dart';
import '../models/mentorship_session.dart';
import '../../core/constants/app_constants.dart';

/// Repository for mentorship operations - Module 4
class MentorshipRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== MENTOR PROFILES ====================

  /// Get all available mentors
  Future<List<MentorProfile>> getAvailableMentors() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorProfiles,
      where: 'isAvailable = 1',
      orderBy: 'rating DESC',
    );
    return maps.map((map) => MentorProfile.fromMap(map)).toList();
  }

  /// Get mentor profile by user ID
  Future<MentorProfile?> getMentorByUserId(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorProfiles,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return MentorProfile.fromMap(maps.first);
  }

  /// Get mentor profile by ID
  Future<MentorProfile?> getMentorById(int mentorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorProfiles,
      where: 'id = ?',
      whereArgs: [mentorId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return MentorProfile.fromMap(maps.first);
  }

  /// Search mentors by expertise
  Future<List<MentorProfile>> searchMentorsByExpertise(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorProfiles,
      where: 'expertise LIKE ? AND isAvailable = 1',
      whereArgs: ['%$query%'],
      orderBy: 'rating DESC',
    );
    return maps.map((map) => MentorProfile.fromMap(map)).toList();
  }

  /// Create a mentor profile
  Future<int> createMentorProfile(MentorProfile profile) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableMentorProfiles,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update mentor profile
  Future<int> updateMentorProfile(MentorProfile profile) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableMentorProfiles,
      profile.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Update mentor availability
  Future<void> updateAvailability(int mentorId, bool isAvailable) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMentorProfiles,
      {
        'isAvailable': isAvailable ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [mentorId],
    );
  }

  /// Update mentor rating
  Future<void> updateRating(int mentorId, double newRating) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMentorProfiles,
      {
        'rating': newRating,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [mentorId],
    );
  }

  /// Increment total students count
  Future<void> incrementTotalStudents(int mentorId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableMentorProfiles} SET totalStudents = totalStudents + 1 WHERE id = ?',
      [mentorId],
    );
  }

  /// Increment total sessions count
  Future<void> incrementTotalSessions(int mentorId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableMentorProfiles} SET totalSessions = totalSessions + 1 WHERE id = ?',
      [mentorId],
    );
  }

  // ==================== MENTORSHIP REQUESTS ====================

  /// Get all requests for a student
  Future<List<MentorshipRequest>> getStudentRequests(String studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipRequests,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MentorshipRequest.fromMap(map)).toList();
  }

  /// Get all requests for a mentor
  Future<List<MentorshipRequest>> getMentorRequests(String mentorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipRequests,
      where: 'mentorId = ?',
      whereArgs: [mentorId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MentorshipRequest.fromMap(map)).toList();
  }

  /// Get pending requests for a mentor
  Future<List<MentorshipRequest>> getPendingRequests(String mentorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipRequests,
      where: 'mentorId = ? AND status = ?',
      whereArgs: [mentorId, 'pending'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MentorshipRequest.fromMap(map)).toList();
  }

  /// Create a mentorship request
  Future<int> createRequest(MentorshipRequest request) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableMentorshipRequests,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update request status
  Future<void> updateRequestStatus(
      int requestId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMentorshipRequests,
      {
        'status': status,
        'respondedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  /// Delete a request
  Future<int> deleteRequest(int requestId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableMentorshipRequests,
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  // ==================== MENTORSHIP SESSIONS ====================

  /// Get all sessions for a student
  Future<List<MentorshipSession>> getStudentSessions(String studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipSessions,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'scheduledTime DESC',
    );
    return maps.map((map) => MentorshipSession.fromMap(map)).toList();
  }

  /// Get all sessions for a mentor
  Future<List<MentorshipSession>> getMentorSessions(String mentorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipSessions,
      where: 'mentorId = ?',
      whereArgs: [mentorId],
      orderBy: 'scheduledTime DESC',
    );
    return maps.map((map) => MentorshipSession.fromMap(map)).toList();
  }

  /// Get upcoming sessions for a user
  Future<List<MentorshipSession>> getUpcomingSessions(String userId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final maps = await db.query(
      AppConstants.tableMentorshipSessions,
      where: '(studentId = ? OR mentorId = ?) AND status = ? AND scheduledTime > ?',
      whereArgs: [userId, userId, 'scheduled', now],
      orderBy: 'scheduledTime ASC',
    );
    return maps.map((map) => MentorshipSession.fromMap(map)).toList();
  }

  /// Get a session by ID
  Future<MentorshipSession?> getSessionById(int sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMentorshipSessions,
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return MentorshipSession.fromMap(maps.first);
  }

  /// Create a mentorship session
  Future<int> createSession(MentorshipSession session) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableMentorshipSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update session
  Future<int> updateSession(MentorshipSession session) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableMentorshipSessions,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Update session status
  Future<void> updateSessionStatus(int sessionId, String status) async {
    final db = await _dbHelper.database;
    
    final data = <String, dynamic>{'status': status};
    
    if (status == 'completed') {
      data['completedAt'] = DateTime.now().toIso8601String();
    }
    
    await db.update(
      AppConstants.tableMentorshipSessions,
      data,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Add session rating
  Future<void> rateSession(int sessionId, int rating, String? notes) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableMentorshipSessions,
      {
        'rating': rating,
        'notes': notes,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Delete a session
  Future<int> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableMentorshipSessions,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
