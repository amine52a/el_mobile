import 'package:flutter/foundation.dart';
import '../data/models/mentor_profile.dart';
import '../data/models/mentorship_request.dart';
import '../data/models/mentorship_session.dart';
import '../services/mentorship_service.dart';

/// Provider for mentorship state management - Module 4
class MentorshipProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();

  // State
  List<MentorProfile> _mentors = [];
  MentorProfile? _currentMentor;
  List<MentorshipRequest> _requests = [];
  List<MentorshipSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MentorProfile> get mentors => _mentors;
  MentorProfile? get currentMentor => _currentMentor;
  List<MentorshipRequest> get requests => _requests;
  List<MentorshipSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== MENTORS ====================

  /// Load all available mentors
  Future<void> loadMentors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mentors = await _service.getAvailableMentors();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des mentors: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search mentors by expertise
  Future<void> searchMentors(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mentors = await _service.searchMentors(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific mentor
  Future<void> loadMentor(int mentorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentMentor = await _service.getMentorById(mentorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement du profil: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load mentor by user ID
  Future<void> loadMentorByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentMentor = await _service.getMentorByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement du profil: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get top-rated mentors
  Future<void> loadTopMentors({int limit = 5}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mentors = await _service.getTopMentors(limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== REQUESTS ====================

  /// Load requests for a student
  Future<void> loadStudentRequests(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _service.getStudentRequests(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des demandes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load requests for a mentor
  Future<void> loadMentorRequests(String mentorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _service.getMentorRequests(mentorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des demandes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pending requests for a mentor
  Future<void> loadPendingRequests(String mentorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _service.getPendingRequests(mentorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a mentorship request
  Future<int?> createRequest({
    required String studentId,
    required String mentorId,
    required String topic,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if can request
      final canRequest = await _service.canRequestMentor(studentId, mentorId);
      if (!canRequest) {
        _error = 'Vous avez déjà une demande en cours avec ce mentor';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final requestId = await _service.createRequest(
        studentId: studentId,
        mentorId: mentorId,
        topic: topic,
        message: message,
      );

      if (requestId > 0) {
        // Reload requests
        await loadStudentRequests(studentId);
      }

      _isLoading = false;
      notifyListeners();
      return requestId;
    } catch (e) {
      _error = 'Erreur lors de la création de la demande: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Accept a request
  Future<bool> acceptRequest(int requestId, String mentorId) async {
    try {
      await _service.acceptRequest(requestId);
      await loadMentorRequests(mentorId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'acceptation: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reject a request
  Future<bool> rejectRequest(int requestId, String mentorId) async {
    try {
      await _service.rejectRequest(requestId);
      await loadMentorRequests(mentorId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du refus: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== SESSIONS ====================

  /// Load sessions for a student
  Future<void> loadStudentSessions(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _service.getStudentSessions(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des sessions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load sessions for a user (student or mentor)
  Future<void> loadUserSessions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try loading as student first, then merge with mentor sessions
      final studentSessions = await _service.getStudentSessions(userId);
      final mentorSessions = await _service.getMentorSessions(userId);
      
      // Combine and remove duplicates
      final allSessions = {...studentSessions, ...mentorSessions}.toList();
      allSessions.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      
      _sessions = allSessions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des sessions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load sessions for a mentor
  Future<void> loadMentorSessions(String mentorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _service.getMentorSessions(mentorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des sessions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load upcoming sessions
  Future<void> loadUpcomingSessions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _service.getUpcomingSessions(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Schedule a session
  Future<int?> scheduleSession({
    required int requestId,
    required String studentId,
    required String mentorId,
    required DateTime scheduledTime,
    int durationMinutes = 60,
    required String topic,
    String? meetingLink,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessionId = await _service.scheduleSession(
        requestId: requestId,
        studentId: studentId,
        mentorId: mentorId,
        scheduledTime: scheduledTime,
        durationMinutes: durationMinutes,
        topic: topic,
        meetingLink: meetingLink,
      );

      if (sessionId > 0) {
        await loadMentorSessions(mentorId);
      }

      _isLoading = false;
      notifyListeners();
      return sessionId;
    } catch (e) {
      _error = 'Erreur lors de la planification: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Complete a session
  Future<bool> completeSession(int sessionId, String userId) async {
    try {
      await _service.completeSession(sessionId);
      await loadStudentSessions(userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel a session
  Future<bool> cancelSession(int sessionId, String userId) async {
    try {
      await _service.cancelSession(sessionId);
      await loadStudentSessions(userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return false;
    }
  }

  /// Rate a session
  Future<bool> rateSession(int sessionId, int rating, String? notes, String userId) async {
    try {
      await _service.rateSession(sessionId, rating, notes);
      await loadStudentSessions(userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'évaluation: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Get mentor stats
  Future<Map<String, dynamic>> getMentorStats(String mentorId) async {
    return await _service.getMentorStats(mentorId);
  }

  /// Get student stats
  Future<Map<String, int>> getStudentStats(String studentId) async {
    return await _service.getStudentStats(studentId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
