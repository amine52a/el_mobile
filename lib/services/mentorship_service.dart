import '../data/models/mentor_profile.dart';
import '../data/models/mentorship_request.dart';
import '../data/models/mentorship_session.dart';
import '../data/repositories/mentorship_repository.dart';

/// Service for managing mentorship-related business logic - Module 4
class MentorshipService {
  final MentorshipRepository _repository = MentorshipRepository();

  // ==================== MENTOR PROFILES METHODS ====================

  /// Get all available mentors
  Future<List<MentorProfile>> getAvailableMentors() async {
    return await _repository.getAvailableMentors();
  }

  /// Get mentor profile by user ID
  Future<MentorProfile?> getMentorByUserId(String userId) async {
    return await _repository.getMentorByUserId(userId);
  }

  /// Get mentor profile by ID
  Future<MentorProfile?> getMentorById(int mentorId) async {
    return await _repository.getMentorById(mentorId);
  }

  /// Search mentors by expertise
  Future<List<MentorProfile>> searchMentors(String query) async {
    if (query.trim().isEmpty) {
      return await getAvailableMentors();
    }
    return await _repository.searchMentorsByExpertise(query);
  }

  /// Create a mentor profile
  Future<int> createMentorProfile({
    required String userId,
    required String expertise,
    required String bio,
    List<String> languages = const [],
    List<String> availableDays = const [],
    String? availableTimeSlot,
  }) async {
    final profile = MentorProfile(
      userId: userId,
      expertise: expertise,
      bio: bio,
      languages: languages,
      availableDays: availableDays,
      availableTimeSlot: availableTimeSlot,
    );

    return await _repository.createMentorProfile(profile);
  }

  /// Update mentor profile
  Future<bool> updateMentorProfile(MentorProfile profile) async {
    final result = await _repository.updateMentorProfile(profile);
    return result > 0;
  }

  /// Toggle mentor availability
  Future<void> toggleAvailability(int mentorId, bool isAvailable) async {
    await _repository.updateAvailability(mentorId, isAvailable);
  }

  /// Calculate and update mentor rating based on session ratings
  Future<void> updateMentorRating(int mentorId, String mentorUserId) async {
    // Get all completed sessions for this mentor
    final sessions = await _repository.getMentorSessions(mentorUserId);
    final completedSessions = sessions.where((s) => 
      s.isCompleted && s.rating != null
    ).toList();

    if (completedSessions.isEmpty) return;

    // Calculate average rating
    double total = 0;
    for (var session in completedSessions) {
      total += session.rating!;
    }
    final average = total / completedSessions.length;

    // Update mentor rating
    await _repository.updateRating(mentorId, average);
  }

  // ==================== MENTORSHIP REQUESTS METHODS ====================

  /// Get all requests for a student
  Future<List<MentorshipRequest>> getStudentRequests(String studentId) async {
    return await _repository.getStudentRequests(studentId);
  }

  /// Get all requests for a mentor
  Future<List<MentorshipRequest>> getMentorRequests(String mentorId) async {
    return await _repository.getMentorRequests(mentorId);
  }

  /// Get pending requests for a mentor
  Future<List<MentorshipRequest>> getPendingRequests(String mentorId) async {
    return await _repository.getPendingRequests(mentorId);
  }

  /// Create a mentorship request
  Future<int> createRequest({
    required String studentId,
    required String mentorId,
    required String topic,
    required String message,
  }) async {
    final request = MentorshipRequest(
      studentId: studentId,
      mentorId: mentorId,
      topic: topic,
      message: message,
    );

    return await _repository.createRequest(request);
  }

  /// Accept a mentorship request
  Future<void> acceptRequest(int requestId) async {
    await _repository.updateRequestStatus(requestId, 'accepted');
  }

  /// Reject a mentorship request
  Future<void> rejectRequest(int requestId) async {
    await _repository.updateRequestStatus(requestId, 'rejected');
  }

  /// Delete a request
  Future<bool> deleteRequest(int requestId) async {
    final result = await _repository.deleteRequest(requestId);
    return result > 0;
  }

  // ==================== MENTORSHIP SESSIONS METHODS ====================

  /// Get all sessions for a student
  Future<List<MentorshipSession>> getStudentSessions(String studentId) async {
    return await _repository.getStudentSessions(studentId);
  }

  /// Get all sessions for a mentor
  Future<List<MentorshipSession>> getMentorSessions(String mentorId) async {
    return await _repository.getMentorSessions(mentorId);
  }

  /// Get upcoming sessions for a user
  Future<List<MentorshipSession>> getUpcomingSessions(String userId) async {
    return await _repository.getUpcomingSessions(userId);
  }

  /// Get a session by ID
  Future<MentorshipSession?> getSessionById(int sessionId) async {
    return await _repository.getSessionById(sessionId);
  }

  /// Schedule a new mentorship session
  Future<int> scheduleSession({
    required int requestId,
    required String studentId,
    required String mentorId,
    required DateTime scheduledTime,
    int durationMinutes = 60,
    required String topic,
    String? meetingLink,
  }) async {
    final session = MentorshipSession(
      requestId: requestId,
      studentId: studentId,
      mentorId: mentorId,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      topic: topic,
      meetingLink: meetingLink,
    );

    final sessionId = await _repository.createSession(session);
    
    // Increment mentor's total sessions
    final mentorProfile = await getMentorByUserId(mentorId);
    if (mentorProfile != null) {
      await _repository.incrementTotalSessions(mentorProfile.id!);
    }
    
    return sessionId;
  }

  /// Update a session
  Future<bool> updateSession(MentorshipSession session) async {
    final result = await _repository.updateSession(session);
    return result > 0;
  }

  /// Complete a session
  Future<void> completeSession(int sessionId) async {
    await _repository.updateSessionStatus(sessionId, 'completed');
    
    // Get session to increment mentor stats
    final session = await getSessionById(sessionId);
    if (session != null) {
      final mentorProfile = await getMentorByUserId(session.mentorId);
      if (mentorProfile != null) {
        // Check if this is the first completed session with this student
        final studentSessions = await getStudentSessions(session.studentId);
        final completedWithMentor = studentSessions.where((s) => 
          s.mentorId == session.mentorId && s.isCompleted
        ).length;
        
        // If first completed session, increment total students
        if (completedWithMentor == 1) {
          await _repository.incrementTotalStudents(mentorProfile.id!);
        }
      }
    }
  }

  /// Cancel a session
  Future<void> cancelSession(int sessionId) async {
    await _repository.updateSessionStatus(sessionId, 'cancelled');
  }

  /// Rate a session
  Future<void> rateSession(int sessionId, int rating, String? notes) async {
    await _repository.rateSession(sessionId, rating, notes);
    
    // Update mentor's overall rating
    final session = await getSessionById(sessionId);
    if (session != null) {
      final mentorProfile = await getMentorByUserId(session.mentorId);
      if (mentorProfile != null) {
        await updateMentorRating(mentorProfile.id!, session.mentorId);
      }
    }
  }

  /// Delete a session
  Future<bool> deleteSession(int sessionId) async {
    final result = await _repository.deleteSession(sessionId);
    return result > 0;
  }

  // ==================== UTILITY METHODS ====================

  /// Get mentor statistics
  Future<Map<String, dynamic>> getMentorStats(String mentorId) async {
    final profile = await getMentorByUserId(mentorId);
    if (profile == null) {
      return {
        'totalStudents': 0,
        'totalSessions': 0,
        'rating': 0.0,
        'pendingRequests': 0,
      };
    }

    final pendingRequests = await getPendingRequests(mentorId);

    return {
      'totalStudents': profile.totalStudents,
      'totalSessions': profile.totalSessions,
      'rating': profile.rating,
      'pendingRequests': pendingRequests.length,
    };
  }

  /// Get student statistics
  Future<Map<String, int>> getStudentStats(String studentId) async {
    final sessions = await getStudentSessions(studentId);
    final requests = await getStudentRequests(studentId);

    return {
      'totalSessions': sessions.length,
      'completedSessions': sessions.where((s) => s.isCompleted).length,
      'upcomingSessions': sessions.where((s) => s.isScheduled && s.isUpcoming).length,
      'totalRequests': requests.length,
      'pendingRequests': requests.where((r) => r.isPending).length,
    };
  }

  /// Get top-rated mentors
  Future<List<MentorProfile>> getTopMentors({int limit = 5}) async {
    final mentors = await getAvailableMentors();
    
    // Sort by rating
    mentors.sort((a, b) => b.rating.compareTo(a.rating));
    
    // Return top N
    return mentors.take(limit).toList();
  }

  /// Check if student can request a specific mentor
  Future<bool> canRequestMentor(String studentId, String mentorId) async {
    // Check if there's already a pending request
    final requests = await getStudentRequests(studentId);
    final pendingWithMentor = requests.where((r) => 
      r.mentorId == mentorId && r.isPending
    ).toList();

    return pendingWithMentor.isEmpty;
  }
}
